_ = require 'underscore'
functions = require '../functions'
{EventEmitter} = require 'events'
Promise = require 'bluebird'
Datastore = require 'nedb'
CHANGE_EVENT = 'STORE_CHANGE'
class Store
  @stores = {}
  @emitter: new EventEmitter()
  @_store: () ->
    store = @stores[@name]
    if not store?
      store = new Datastore()
      Promise.promisifyAll(store)
      @stores[@name] = store
    store
  @find: (id) ->
    new Promise (resolve, reject) =>
      @_store().findOneAsync _id: id
      .then (doc) =>
        if doc? then new this(doc) else null
      .then (obj) ->
        if obj?
          obj.load().then (obj) ->
            resolve(obj)
        else
          resolve(obj)
  @findOrCreate: (opts={}) ->
    new Promise (resolve, reject) =>
      @_store().findOneAsync _id: opts?.id
      .then (doc) =>
        if doc? then new this(doc) else new this(opts)
      .then (obj) ->
        obj.load().then (obj) ->
          resolve(obj)
  @findBy: (query={}) ->
    @_store().findAsync query
    .map (doc) =>
      this.new(doc)
    .all()
  @findByOrCreate: (query, opts, defaultArgs) ->
    @_store().findAsync query
    .then (docs) ->
      if docs.length > 0
        docs
      else if opts?
        opts.map (opt) ->
          _.extend(opt, query)
      else if defaultArgs?
        defaultArgs()
      else
        []
    .map (args) =>
      this.new(args)
    .all()
  @all: () ->
    @findBy()
  @new: (opts={}) ->
    new this(opts).load()
  @emitChange: () =>
    console.log "EMIT CHANGE"
    @emitter.emit(CHANGE_EVENT)
  @addChangeListener: (callback) ->
    @emitter.on(CHANGE_EVENT, callback)
  @removeChangeListener: (callback) ->
    @emitter.removeListener(CHANGE_EVENT, callback)
  constructor: (options={}) ->
    @id = options.id ? functions.uniqueId()
    @_id = @id
  load: () ->
    Promise.resolve(this)
  save: (cascade=false) ->
    @constructor._store().update({_id: @_id}, this, {upsert: true}, @constructor.emitChange)
  destroy: () ->
    @constructor._store().remove({_id: @_id}, {}, @constructor.emitChange)
module.exports = Store

unless localStorage?
  {LocalStorage} = require('node-localstorage')
  GLOBAL.localStorage = new LocalStorage('./scratch')
config = require('./scripts/config')
module.exports = start: (port=3000) ->
  config.set('socketUrl', "localhost:#{port}")
  express = require('express')
  app = express();
  http = require('http').Server(app);
  io = require('socket.io')(http);
  constants = require('./scripts/constants')
  GameState = require('./scripts/models/game_state')
  AppDispatcher = require('./scripts/dispatcher/app_dispatcher')
  {ActionTypes} = require './scripts/constants'
  app.use '/', express.static(__dirname)
  games = GameState.all()
  GameState.addChangeListener () ->
    games = GameState.all()
  io.on 'connection', (socket) ->
    console.log('a user connected')
    socket.emit 'connected'
    games.map (game) ->
      game.getMetadata()
    .then (metadata) ->
      socket.emit 'app dispatcher',
        type: ActionTypes.SYNC_GAMES
        games: metadata
    socket.on 'disconnect', () ->
      console.log('user disconnected')
    socket.on 'app dispatcher', (action) ->
      AppDispatcher.dispatch(action)
      socket.broadcast.emit 'app dispatcher', action
    socket.on 'sync clocks', () ->
      timeX = new Date().getTime()
      setTimeout( ()->
        timeY = new Date().getTime()
        socket.emit 'clocks synced',
          timeX: timeX
          timeY: timeY
      ,constants.CLOCK_SYNC_DELAY_DURATION_IN_MS)
    socket.on 'sync game', (payload) ->
      GameState.find(payload.gameId).then (game) ->
        socket.emit 'app dispatcher',
          type: ActionTypes.SAVE_GAME
          gameState: game
  http.listen port, () ->
    console.log("listening on *:#{port}")

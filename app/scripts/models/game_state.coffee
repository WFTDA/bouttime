moment = require 'moment'
$ = require 'jquery'
_ = require 'underscore'
Promise = require 'bluebird'
functions = require '../functions'
AppDispatcher = require '../dispatcher/app_dispatcher'
Store = require './store'
{ClockManager} = require '../clock'
Team = require './team'
GameMetadata = require './game_metadata'
{ActionTypes} = require '../constants'
constants = require '../constants'
PERIOD_CLOCK_SETTINGS =
  time: constants.PERIOD_DURATION_IN_MS
PREGAME_CLOCK_SETTINGS =
  time: constants.PREGAME_DURATION_IN_MS
HALFTIME_CLOCK_SETTINGS =
  time: constants.HALFTIME_DURATION_IN_MS
JAM_CLOCK_SETTINGS =
  time: constants.JAM_DURATION_IN_MS
  warningTime: constants.JAM_WARNING_IN_MS
LINEUP_CLOCK_SETTINGS =
  time: constants.LINEUP_DURATION_IN_MS
TIMEOUT_CLOCK_SETTINGS =
  time: 0
  tickUp: true
class GameState extends Store
  @dispatchToken: AppDispatcher.register (action) =>
    @find(action.gameId).then (game) =>
      switch action.type
        when ActionTypes.START_CLOCK
          game.startClock()
          game.syncClocks(action)
        when ActionTypes.STOP_CLOCK
          game.stopClock()
          game.syncClocks(action)
        when ActionTypes.START_JAM
          game.startJam()
          game.syncClocks(action)
        when ActionTypes.STOP_JAM
          game.stopJam()
          game.syncClocks(action)
        when ActionTypes.START_LINEUP
          game.startLineup()
          game.syncClocks(action)
        when ActionTypes.START_PREGAME
          game.startPregame()
          game.syncClocks(action)
        when ActionTypes.START_HALFTIME
          game.startHalftime()
          game.syncClocks(action)
        when ActionTypes.START_UNOFFICIAL_FINAL
          game.startUnofficialFinal()
          game.syncClocks(action)
        when ActionTypes.START_OFFICIAL_FINAL
          game.startOfficialFinal()
          game.syncClocks(action)
        when ActionTypes.START_TIMEOUT
          game.startTimeout()
          game.syncClocks(action)
        when ActionTypes.SET_TIMEOUT_AS_OFFICIAL_TIMEOUT
          game.setTimeoutAsOfficialTimeout()
        when ActionTypes.SET_TIMEOUT_AS_HOME_TEAM_TIMEOUT
          game.setTimeoutAsHomeTeamTimeout()
        when ActionTypes.SET_TIMEOUT_AS_HOME_TEAM_OFFICIAL_REVIEW
          game.setTimeoutAsHomeTeamOfficialReview()
        when ActionTypes.SET_TIMEOUT_AS_AWAY_TEAM_TIMEOUT
          game.setTimeoutAsAwayTeamTimeout()
        when ActionTypes.SET_TIMEOUT_AS_AWAY_TEAM_OFFICIAL_REVIEW
          game.setTimeoutAsAwayTeamOfficialReview()
        when ActionTypes.SET_JAM_ENDED_BY_TIME
          game.setJamEndedByTime()
        when ActionTypes.HANDLE_CLOCK_EXPIRATION
          game.handleClockExpiration()
        when ActionTypes.SET_JAM_CLOCK
          game.setJamClock(action.value)
        when ActionTypes.SET_PERIOD_CLOCK
          game.setPeriodClock(action.value)
        when ActionTypes.SET_HOME_TEAM_TIMEOUTS
          game.setHomeTeamTimeouts(action.value)
        when ActionTypes.SET_AWAY_TEAM_TIMEOUTS
          game.setAwayTeamTimeouts(action.value)
        when ActionTypes.SET_PERIOD
          game.setPeriod(action.value)
        when ActionTypes.SET_JAM_NUMBER
          game.setJamNumber(action.value)
        when ActionTypes.REMOVE_HOME_TEAM_OFFICIAL_REVIEW
          game.removeHomeTeamOfficialReview()
        when ActionTypes.REMOVE_AWAY_TEAM_OFFICIAL_REVIEW
          game.removeAwayTeamOfficialReview()
        when ActionTypes.RESTORE_HOME_TEAM_OFFICIAL_REVIEW
          game.restoreHomeTeamOfficialReview()
        when ActionTypes.RESTORE_AWAY_TEAM_OFFICIAL_REVIEW
          game.restoreAwayTeamOfficialReview()
        when ActionTypes.SAVE_GAME
          GameState.new(action.gameState).then (gs) ->
            gs.syncClocks(action.gameState)
            gs.save(true)
      game.save() if game?
  constructor: (options={}) ->
    super options
    @name = options.name
    @venue = options.venue
    @date = options.date
    @time = options.time
    @officials = options.officials ? []
    @debug = options.debug ? false
    @state = options.state ? 'pregame'
    @period = options.period ? 'pregame'
    @jamNumber = options.jamNumber ? 0
    @clockManager = new ClockManager()
    @jamClock = @clockManager.getOrAddClock "jamClock-#{@id}", options.jamClock ? PREGAME_CLOCK_SETTINGS
    @periodClock = @clockManager.getOrAddClock "periodClock-#{@id}", options.periodClock ? PERIOD_CLOCK_SETTINGS
    @timeout = options.timeout ? null
    @home = options.home
    @away = options.away
    @penalties = [
      {code: "A", name: "High Block"},
      {code: "N", name: "Insubordination"},
      {code: "B", name: "Back Block"},
      {code: "S", name: "Skating Out of Bnds."},
      {code: "E", name: "Elbows"},
      {code: "X", name: "Cutting the Track"},
      {code: "F", name: "Forearms"},
      {code: "Z", name: "Delay of Game"},
      {code: "G", name: "Misconduct"},
      {code: "C", name: "Dir. of Game Play"},
      {code: "H", name: "Blocking with Head"},
      {code: "O", name: "Out of Bounds"},
      {code: "L", name: "Low Block"},
      {code: "P", name: "Out of Play"},
      {code: "M", name: "Multi-Player Block"},
      {code: "I", name: "Illegal Procedure"},
      {code: "G", name: "Gross Misconduct"}
    ]
  load: (options={}) ->
    home = Team.findOrCreate(@home).then (home) =>
      @home = home
    away = Team.findOrCreate(@away).then (away) =>
      @away = away    
    Promise.join(home, away).return(this)
  save: (cascade=false) ->
    super()
    if cascade
      @home.save(true)
      @away.save(true)
  getDisplayName: () ->
    "#{moment(@date, 'MM/DD/YYYY').format('YYYY-MM-DD')} #{@home.name} vs #{@away.name}"
  getCurrentJam: (team) ->
    (jam for jam in team.jams when jam.jamNumber is @jamNumber)[0]
  syncClocks: (clocks) ->
    @jamClock.reset (clocks.jamClock)
    @periodClock.reset (clocks.periodClock)
    if clocks.sourceDelay? and clocks.destinationDelay?
      delta = (clocks.sourceDelay + clocks.destinationDelay) / 2.0
      @jamClock.tick(delta)
      @periodClock.tick(delta)
  startClock: ()->
    @jamClock.start()
  stopClock: () ->
    @jamClock.stop()
  advancePeriod: () ->
    if @period is "pregame"
      @period = "period 1"
      @periodClock.reset(PERIOD_CLOCK_SETTINGS)
    else if @period is "halftime"
      @period = "period 2"
      @periodClock.reset(PERIOD_CLOCK_SETTINGS)
  startJam: () ->
    @_clearTimeouts()
    @jamClock.reset(JAM_CLOCK_SETTINGS)
    @jamClock.start()
    @advancePeriod()
    @periodClock.start()
    @state = "jam"
    @jamNumber = @jamNumber + 1
    @home.createJamsThrough @jamNumber
    @away.createJamsThrough @jamNumber
  stopJam: () =>
    @jamClock.stop()
    @startLineup()
  startLineup: () =>
    @_clearTimeouts()
    @jamClock.reset(LINEUP_CLOCK_SETTINGS)
    @jamClock.start()
    @state = "lineup"
  startPregame: () =>
    @periodClock.reset(time: 0)
    @state = "pregame"
    @period = "pregame"
    @jamClock.reset(PREGAME_CLOCK_SETTINGS)
  startHalftime: () =>
    @periodClock.reset(time: 0)
    @state = "halftime"
    @period = "halftime"
    @jamClock.reset(HALFTIME_CLOCK_SETTINGS)
  startUnofficialFinal: () =>
    @state = "unofficial final"
    @period = "unofficial final"
  startOfficialFinal: () =>
    @state = "official final"
    @period = "official final"
  startTimeout: () =>
    @_stopClocks()
    @jamClock.reset(TIMEOUT_CLOCK_SETTINGS)
    @jamClock.start()
    @state = "timeout"
    @timeout = null
  setTimeoutAsOfficialTimeout: () =>
    if @_inTimeout() == false
      @startTimeout()
    @_clearTimeouts()
    @timeout = "official_timeout"
    @inOfficialTimeout = true
  setTimeoutAsHomeTeamTimeout: () =>
    if @_inTimeout() == false
      @startTimeout()
    @_clearTimeouts()
    @timeout = "home_team_timeout"
    @home.startTimeout()
  setTimeoutAsHomeTeamOfficialReview: () =>
    if @_inTimeout() == false
      @startTimeout()
    @_clearTimeouts()
    @home.hasOfficialReview = false
    @home.isTakingOfficialReview = true
    @timeout = "home_team_official_review"
  setTimeoutAsAwayTeamTimeout: () =>
    if @_inTimeout() == false
      @startTimeout()
    @_clearTimeouts()
    @state = "timeout"
    @timeout = "away_team_timeout"
    @away.startTimeout()
  setTimeoutAsAwayTeamOfficialReview: () =>
    if @_inTimeout() == false
      @startTimeout()
    @_clearTimeouts()
    @away.hasOfficialReview = false
    @away.isTakingOfficialReview = true
    @state = "timeout"
    @timeout = "away_team_official_review"
  handleClockExpiration: () =>
    if @state == "jam"
      #Mark as jam ended by time
      @stopJam()
  setJamEndedByCalloff: () =>
  setJamClock: (val) =>
    @jamClock.reset(_.extend(@jamClock, time: val))
  setPeriodClock: (val) =>
    @periodClock.reset(_.extend(@periodClock, time: val))
  setHomeTeamTimeouts: (val) =>
    @home.timeouts = parseInt(val)
  setAwayTeamTimeouts: (val) =>
    @away.timeouts = parseInt(val)
  setPeriod: (val) =>
    @period = val
  setJamNumber: (val) =>
    @jamNumber = parseInt(val)
  removeHomeTeamOfficialReview: () =>
    @home.removeOfficialReview()
  removeAwayTeamOfficialReview: () =>
    @away.removeOfficialReview()
  restoreHomeTeamOfficialReview: () =>
    @_clearTimeouts()
    @home.restoreOfficialReview()
  restoreAwayTeamOfficialReview: () =>
    @_clearTimeouts()
    @away.restoreOfficialReview()
  getMetadata: () ->
    new GameMetadata
      id: @id
      display: @getDisplayName()
  _inTimeout: ()->
      @state == "timeout"
  _clearAlerts: () =>
    @_clearTimeouts()
  _clearTimeouts: () =>
    @home.isTakingTimeout = false
    @away.isTakingTimeout = false
    @home.isTakingOfficialReview = false
    @away.isTakingOfficialReview = false
  _buildOptions: (opts = {}) =>
    std_opts =
      role: 'Jam Timer'
      state: @state
    $.extend(std_opts, opts)
  _stopClocks: () ->
    @jamClock.stop()
    @periodClock.stop()
module.exports = GameState

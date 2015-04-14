React = require 'react/addons'
constants = require '../constants.coffee'
functions = require '../functions.coffee'
GameState = require '../models/game_state.coffee'
Titlebar = require './titlebar.cjsx'
Navbar = require './navbar.cjsx'
JamTimer = require './jam_timer.cjsx'
LineupTracker = require './lineup_tracker.cjsx'
Scorekeeper = require './scorekeeper.cjsx'
PenaltyTracker = require './penalty_tracker.cjsx'
PenaltyBoxTimer = require './penalty_box_timer.cjsx'
Scoreboard = require './scoreboard.cjsx'
PenaltyWhiteboard = require './penalty_whiteboard.cjsx'
AnnouncersFeed = require './announcers_feed.cjsx'
GameNotes = require './game_notes.cjsx'
GameSetup = require './game_setup.cjsx'
Login = require './login.cjsx'
SkaterSelectorModal = require './shared/skater_selector_modal.cjsx'
cx = React.addons.classSet
module.exports = React.createClass
  displayName: 'Game'
  componentDidMount: () ->
    $dom = $(@getDOMNode())
    @gameDOM = $(".game")
    $dom.on 'click', '.bad-status', null, (evt) ->
    $dom.on 'click', 'ul.nav li', null, (evt) =>
      @setState
        tab: evt.currentTarget.dataset.tabName
    $dom.on 'click', '#setup', null, (evt) =>
      @setState
        tab: "game_setup"
    $dom.on 'click', '#login', null, (evt) =>
      @setState
        tab: "login"
    GameState.addChangeListener @onChange
  componentWillUnmount: () ->
    GameState.removeChangeListener @onChange
  resetDeadmanTimer: () ->
    clearTimeout(exports.connectionTimeout)
    @gameDOM.addClass("connected")
    exports.connectionTimeout = setInterval(() =>
      @gameDOM.removeClass("connected")
    , constants.CLOCK_REFRESH_RATE_IN_MS*2)
  loadGameState: () ->
    GameState.find(@props.gameStateId)
  onChange: () ->
    @setState(gameState: @loadGameState())
  getInitialState: () ->
    gameState = @loadGameState()
    gameState: gameState
    tab: "jam_timer"
    skaterSelectorContext:
      team: gameState.away
      jam: gameState.away.getJams()[0]
      selectHandler: () ->
  setSelectorContext: (team, jam, selectHandler) ->
    @setState
      skaterSelectorContext:
        team: team
        jam: jam
        selectHandler: selectHandler
  render: () ->
    <div ref="game" className="game" data-tab={@state.tab}>
      <header>
        <div className="container-fluid">
          <Titlebar {...this.state} />
          <div className="logo">
            <div className="container">
              <a href="#">
                <img className="hidden-xs" height="64" src="/images/logo.png" />
                <img className="visible-xs-block" height="48" src="/images/logo.png" />
              </a>
            </div>
          </div>
          <Navbar tab={@state.tab}/>
        </div>
      </header>
      <div className="container">
        <JamTimer {...@state} />
        <LineupTracker gameState={@state.gameState} setSelectorContext={@setSelectorContext} />
        <Scorekeeper gameState={@state.gameState} setSelectorContext={@setSelectorContext} />
        <PenaltyTracker gameState={@state.gameState} />
        <PenaltyBoxTimer gameState={@state.gameState} setSelectorContext={@setSelectorContext}/>
        <Scoreboard gameState={@state.gameState} />
        <PenaltyWhiteboard {...@state} />
        <AnnouncersFeed gameState={@state.gameState} />
        <GameNotes gameState={@state.gameState} />
        <GameSetup gameState={@state.gameState} />
        <Login />
      </div>
      <SkaterSelectorModal {...@state.skaterSelectorContext} />
    </div>

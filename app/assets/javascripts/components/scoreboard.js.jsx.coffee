# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
exports = exports ? this
exports.Scoreboard = React.createClass
  getInitialState: () ->
    jamNumber: 1
    periodNumber: 1
    jamClockLabel: "Time To Derby"
    jamClock: "90:00"
    periodClock: "30:00"
    team:
      home:
        name: "Atlanta Rollergirls"
        colorBarStyle:
          backgroundColor: "#2082a6"
        logoURI: "http://placehold.it/350x240"
        points: 0
        jamPoints: 0
        hasOfficialReview: true
        timeouts: 3
        jammer:
          lead: false
          name: "Nattie Long Legs"
      away:
        name: "Gotham Rollergirls"
        colorBarStyle:
          backgroundColor: "#f50031"
        logoURI: "http://placehold.it/350x240"
        points: 0
        jamPoints: 0
        hasOfficialReview: true
        timeouts: 3
        jammer:
          lead: true
          name: "Bonnie Thunders"
  render: () ->
    `<div className="scoreboard" id="scoreboard">
      <section className="team home">
        <div className="logo">
          <img src={this.state.team.home.logoURI} />
        </div>
        <div className="name">{this.state.team.home.name}</div>
        <div className="color-bar" style={this.state.team.home.colorBarStyle}></div>
        <div className="score">{this.state.team.home.points}</div>
        <div className="jammer home-team-jammer">
          <div className="lead-status">
            <span className="glyphicon glyphicon-star" className={this.state.team.home.jammer.lead ? '' : 'hidden'}></span>
          </div>
          <div className="name">{this.state.team.home.jammer.name}</div>
        </div>
        <div className="timeouts home-team-timeouts">
          <div style={this.state.team.home.colorBarStyle} className="timeout-bar official-review {this.state.team.home.hasOfficialReview ? :}"></div>
          <div style={this.state.team.home.colorBarStyle} className="timeout-bar timeout"></div>
          <div style={this.state.team.home.colorBarStyle} className="timeout-bar timeout"></div>
          <div style={this.state.team.home.colorBarStyle} className="timeout-bar timeout"></div>
        </div>
      </section>
      <section className="clocks">
        <div className="clocks-border">
          <div className="period-jam-counts">
            <div className="period">
              <label className="hidden-xs hidden-sm">Period</label>
              <label className="visible-sm-block">Per</label>
              <div className="number period-number">{this.state.periodNumber}</div>
            </div>
            <div className="jam">
              <label>Jam</label>
              <div className="number jam-number">{this.state.jamNumber}</div>
            </div>
          </div>
          <div className="period-clock">
            <label className="hidden">Period Clock</label>
            <div className="clock period-clock">{this.state.periodClock}</div>
          </div>
          <div className="jam-clock">
            <label className="jam-clock-label">{this.state.jamClockLabel}</label>
            <div className="clock">{this.state.jamClock}</div>
          </div>
        </div>
        <div className="jam-points-wrapper">
          <div className="home-team-jam-points points">{this.state.team.home.jamPoints}</div>
          <div className="away-team-jam-points points">{this.state.team.away.jamPoints}</div>
        </div>
      </section>
      <section className="team away">
        <div className="logo">
          <img src={this.state.team.away.logoURI} />
        </div>
        <div className="name">{this.state.team.away.name}</div>
        <div className="color-bar" style={this.state.team.away.colorBarStyle}></div>
        <div className="score">{this.state.team.away.points}</div>
        <div className="jammer away-team-jammer">
          <div className="lead-status">
            <span className="glyphicon glyphicon-star {this.state.team.away.jammer.lead ? '' : 'hidden'}"></span>
          </div>
          <div className="name">{this.state.team.away.jammer.name}</div>
        </div>
        <div className="timeouts away-team-timeouts">
          <div style={this.state.team.away.colorBarStyle} className="timeout-bar official-review {this.state.team.away.hasOfficialReview ? :}"></div>
          <div style={this.state.team.away.colorBarStyle} className="timeout-bar timeout"></div>
          <div style={this.state.team.away.colorBarStyle} className="timeout-bar timeout"></div>
          <div style={this.state.team.away.colorBarStyle} className="timeout-bar timeout"></div>
        </div>
      </section>
      <section className="alerts">
        <div className="alert-home">
          <div className="scoreboard-alert home-team-timeout hidden">timeout</div>
          <div className="scoreboard-alert home-team-official-review hidden">official review</div>
          <div className="scoreboard-alert home-team-unofficial-final hidden">unofficial final</div>
          <div className="scoreboard-alert home-team-final hidden">final</div>
        </div>
        <div className="alert-away">
          <div className="scoreboard-alert away-team-timeout hidden">timeout</div>
          <div className="scoreboard-alert away-team-official-review hidden">official review</div>
          <div className="scoreboard-alert away-team-unofficial-final hidden">final</div>
          <div className="scoreboard-alert away-team-final hidden">final</div>
        </div>
        <div className="alert-neutral">
          <div className="scoreboard-alert generic-timeout hidden">timeout</div>
          <div className="scoreboard-alert official-timeout hidden">official timeout</div>
          <div className="scoreboard-alert unofficial-final hidden">unofficial final</div>
          <div className="scoreboard-alert official-final hidden">final</div>
        </div>
      </section>
      <section className="ads"></section>
      <section className="fly-ins"></section>
    </div>`
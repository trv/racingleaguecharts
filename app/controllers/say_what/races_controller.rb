class SayWhat::RacesController < ApplicationController
  before_filter :find_race, :only => [ :show, :edit, :update, :destroy, :rescan ]
  before_filter :get_sessions, :only => [ :edit ]

  def index
    @races = {}
    Race.order(:created_at).each do |race|
      season = race.try(:season)
      league = season.try(:league)
      super_league = league.try(:super_league)

      super_league = 'Unknown' if super_league.nil?
      league = 'Unknown' if league.nil?
      season = 'Unknown' if season.nil?

      @races[super_league] ||= {}
      @races[super_league][league] ||= {}
      @races[super_league][league][season] ||= []
      @races[super_league][league][season] << race
    end
  end

  def show
    @sessions = if @race.time_trial
      @race.sessions.includes(:laps).order('laps.total')
    else
      @race.sessions.order(:created_at)
    end
  end

  def new
    @race = Race.new
  end

  def edit
  end

  def create
    @race = Race.new(params[:race])

    if @race.save
      redirect_to(say_what_race_path(@race), :notice => 'Race was successfully created.')
    else
      render "new"
    end
  end

  def update
    if @race.update_attributes(params[:race])
      redirect_to(say_what_race_path(@race), :notice => 'Race was successfully updated.')
    else
      render "edit"
    end
  end

  def destroy
    @race.destroy
    redirect_to(say_what_races_url, :notice => 'Race deleted')
  end

  def rescan
    @race.scan_time_trial if @race.time_trial?
    redirect_to(say_what_race_path(@race), :notice => 'Thread scanned')
  end

  private

    def find_race
      @race = Race.find(params[:id].to_i)
    end

    def get_sessions
      @sessions = @race.sessions.collect(&:driver_id)
    end

end

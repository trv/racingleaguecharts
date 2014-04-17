class Driver < ActiveRecord::Base
  attr_accessible :ip, :name, :flair, :colour, :marker, :merge_session_ids, :aliases
  attr_accessor :merge_session_ids, :aliases

  has_many :sessions
  has_many :driver_aliases

  has_one :driver_user
  has_one :user, :through => :driver_user

  before_save :adjust_aliases
  after_save :adjust_sessions

  def claimed?
    if name.blank?
      'Unknown'
    else
      name
    end
  end

  def self.unclaimed?
    Driver.includes(:driver_user).where('driver_users.user_id is null')
  end

  def adjust_sessions
    unless merge_session_ids.nil?
      merge_session_ids.reject!(&:blank?).map!(&:to_i).collect! { |d| Driver.find(d).session_ids }.flatten!

      current = self.sessions.collect(&:id)
      Session.find((merge_session_ids - current)).each do |session|
        session.update_attribute(:driver_id, self.id)
      end
    end
  end

  def adjust_aliases
    unless self.aliases.nil?
      submitted = self.aliases.split(/,/).reject(&:blank?)
      current = self.driver_aliases.collect(&:name)
      (submitted - current).each do |new_alias|
        self.driver_aliases.build(:name => new_alias)
      end
      self.driver_aliases.where(:name => current - submitted).destroy_all
    end
  end

end

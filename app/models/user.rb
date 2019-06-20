class User < ApplicationRecord
  validates :username, presence: true, length: { minimum: 3, maximum: 20 },
            uniqueness: { case_sensitive: false }
  has_many :messages
  has_secure_password
  has_one_attached :avatar
  has_many :friendships
  has_many :friends, through: :friendships

  def self.search(param)
    param.strip!
    param.downcase!
    to_send_back = (username_matches(param)).uniq
    return nil unless to_send_back
    to_send_back
  end

  def self.username_matches(param)
    matches('username', param)
  end

  def self.matches(field_name, param)
    User.where("#{field_name} like ?", "%#{param}%")
  end

  def except_current_user(users)
    users.reject { |user| user.id == self.id }
  end

  def not_friends_with?(friend_id)
    friendships.where(friend_id: friend_id).count < 1
  end
end

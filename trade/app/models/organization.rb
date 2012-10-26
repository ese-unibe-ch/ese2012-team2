  module Models
    class Organization < Models::Trader
      attr_accessor :name, :image, :interests

      @members = []

      def self.named(name,  interests, admin)
        return self.new(name, interests, admin)
      end

      #SH Setup standard values
      def initialize (name, interests, admin)
        self.credits=100
        self.name = name
        self.interests= interests
        @admin = admin
      end

      def admin
        @admin
      end

      def add_member(member)
        @members.push(member)
      end

      def del_member(member)
        @members.delete(member)
      end

      def members
        @members
      end

      def to_s
        self.name
      end

      def image_path
        if self.image.nil? then
          return "/images/organizations/default.png"
        else
          return "/images/organizations/" + self.image
        end
      end
    end
  end
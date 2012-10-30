  module Models
    class Organization < Models::Trader
      attr_accessor :name, :image, :interests

      def self.named(name,  interests, admin)
        return self.new(name, interests, admin)
      end

      #SH Setup standard values
      def initialize (name, interests, admin)
        self.credits=100
        self.name = name
        self.interests= interests
        @admin = admin
        @members = Array.new()
        @members.push(admin)
        @pending_members = Array.new()
      end

      def display_name
        @name
      end

      def admin
        @admin
      end

      def add_member(member)
        @members.push(member)
      end

      def remove_member(member)
        unless member == @admin
           @members.delete(member)
        end
      end

      def members
        @members
      end

      def send_request(member)
        member.add_request self
        @pending_members.push member
      end

      def accept_request(member)
        if @pending_members.include? member
          @pending_members.delete member
          self.add_member member
          member.organization_request.delete self
        end
      end

      def decline_request(member)
        @pending_members.delete member
        member.organization_requets.delete self
      end

      def to_s
        self.name
      end

      def is_member?(user)
        @members.include? user
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
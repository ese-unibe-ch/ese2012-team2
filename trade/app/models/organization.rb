  module Models
    class Organization < Models::Trader

      attr_accessor :admin
      attr_reader :pending_members, :members

      #SH Setup standard values
      def initialize (name, interests, admin, image)
        self.credits=100
        self.display_name = name
        if name.nil? or name.empty?
          raise TradeException, "Empty name"
        end
        self.name = name.downcase.delete(" ")
        self.interests= interests
        self.admin = admin
        self.image = image
        @members = Array.new()
        @members.push(admin)
        @pending_members = Array.new()

        self.overlay.add_organization(self)
      end

      def email
        self.admin.email
      end

      def add_member(member)
        @members.push(member)
      end

      def remove_member(member)
        unless member == @admin
           @members.delete(member)
        end
      end

      def send_request(member)
        member.add_request self
        @pending_members.push member
      end

      def accept_request(member)
        if @pending_members.include? member
          self.pending_members.delete member
          self.add_member member
          member.organization_request.delete self
        end
      end

      def decline_request(member)
        self.pending_members.delete member
        member.organization_request.delete self
      end

      def to_s
        self.display_name
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
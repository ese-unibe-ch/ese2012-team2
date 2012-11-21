  module Models
    class Organization < Models::Trader

      attr_accessor :admins
      attr_reader :pending_members, :members

      #SH Setup standard values
      def initialize (name, interests, admin, image)
        self.credits=100
        self.credits_in_auction = 0
        self.display_name = name
        if name.nil? or name.empty?
          raise TradeException, "Empty name"
        end
        self.name = name.downcase.delete(" ")
        self.interests= interests
        @admins = Array.new()
        @admins.push(admin)
        self.image = image
        @members = Array.new()
        @members.push(admin)
        @pending_members = Array.new()

        self.overlay.add_organization(self)
      end

      def email
        self.admins.last.email
      end

      def add_member(member)
        member.add_activity "has joined organization #{self.name}"
        add_activity "#{member.name} has become a new member"
        @members.push(member)
      end

      def remove_member(member)
        if @admins.include? member
          raise TradeException "Admin can't be removed"
        else
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

      def track_id
        "org$#{self.name}"
      end

      def add_admin(member)
        unless @admins.include? member
             if @members.include? member
               member.add_activity "has become an admin in organization #{self.name}"
               add_activity "has a new admin: #{member.name}"
               @admins.push member
             else
               raise TradeException, "Admin has to be a member"
             end
        end
      end

      def remove_admin(member)
        if @admins.include? member
          if @admins.length > 1
            @admins.delete member
          else
            raise TradeException, "Last admin can not be removed!"
          end
        else
          raise TradeException, "The member #{member} is no admin."
        end
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
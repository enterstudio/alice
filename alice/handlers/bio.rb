module Handlers

  class Bio

    include PoroPlus
    include Behavior::HandlesCommands

    def process
      handle_bio(command_string.content.to_s, sender)
    end

    private

    def handle_bio(quoted)
      if command_string.predicate && ! command_string.content.include?("who is")
        update_bio(command_string.raw_command)
      else
        return_bio
      end
    end

    def return_bio
      who = subject
      who ||= message.sender
      text = "I don't know who that is." unless who
      text = who.formatted_bio if who && who.formatted_bio
      text ||= "I don't seem to know anything about them."
      message.set_response(text)
    end

    def subject
      ::User.from(command_string.components.join(' '))
    end

    def update_bio(quoted)
      return unless quoted
      message.sender.update_bio(quoted)
      message.set_response("I've recorded the details in my notebook.")
    end

  end

end

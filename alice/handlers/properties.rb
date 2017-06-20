module Handlers

  class Properties

    include PoroPlus
    include Behavior::HandlesTriggers

    def get_property
      parser.parse
      sanitized_property = property.to_s.gsub("_", " ").split.last
      response = result(sanitized_property)
      if response.present?
        message.response = response ? "#{response}." : "no."
      elsif subject
        message.response = subject.bio.formatted
      else
        message.response = "#{message.sender_nick}: #{response}"
      end
    rescue
      message.response = "I'm not sure I understand, can you say that another way?"
    end

    private

    def result(property)
      call_result = subject.public_send(property)
      if call_result == false
        "no"
      elsif call_result == true
        "yes"
      end
      call_result
    rescue
      ""
    end

    def subject
      @subject ||= parser.subject
    end

    def property
      parser.property
    end

  end

end

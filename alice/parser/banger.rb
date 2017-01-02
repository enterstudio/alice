module Parser

  class Banger

    attr_accessor :command_string

    include AASM

    aasm do
      state :unparsed, initial: true
      state :bang
      state :verb
      state :preposition
      state :person
      state :object

      event :bang do
        transitions :from => :unparsed, :to => :bang, :guard => :has_bang?
      end

      event :verb do
        transitions :from => :bang, :to => :verb, :guard => :known_verb?
      end

      event :person do
        transitions :from => :verb, :to => :person, :guard => :known_person?
      end

      event :object do
        transitions :from => :verb, :to => :object, :guard => :known_object?
      end

    end

    def self.parse(command_string)
      parser = new(command_string)
      command = parser.parse!
      if command
        {
          command: command,
          topic: ""
        }
      end
    end

    def initialize(command_string)
      self.command_string = command_string
    end

    def parse!
      bang && verb && (known_verb? || person || object) && command
    rescue
      return false
    ensure
      Alice::Util::Logger.info "*** Final banger state is  \"#{aasm.current_state}\" "
      Alice::Util::Logger.info "*** Command state is  \"#{command && command.name}\" "
    end

    def has_bang?
      self.command_string.content[0] == "!"
    end

    def known_verb?
      command.present?
    end

    def known_person?
      User.like(command.predicate) || User.like(command.subject)
    end

    def known_object?
      Item.like(command.subject) ||
      Item.like(command.predicate) ||
      Beverage.like(command.subject) ||
      Beverage.like(command.predicate)
    end

    def command
      return @command if @command
      if @command = Message::Command.any_in(verbs: sentence.verbs.first).first
        @command.subject = sentence.nouns.first
        @command.predicate = sentence.nouns.last
        @command.verb = sentence.verbs.first
      end
      @command
    end

    private

    def sentence
      @sentence ||= Grammar::SentenceParser.parse(command_string.content)
    end

  end

end

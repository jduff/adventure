module Adventure
  module Commands
    def self.something
      attack = Command.new("attack")
      attack.ask = "What would you like to attack?"
      attack.evaluator = lambda do |subject, location|
        if creature = location.creatures.detect{|creature| creature.name.downcase == subject}
          location.creatures.delete(creature)
          "You attack the #{creature.name} and vanquish it!!"
        else
          "You cannot attack something that doesn't exist!"
        end
      end

      take = Command.new("take")
      take.ask = "What would you like to take?"
      take.evaluator = lambda do |subject, location, player|
        result = "You "
        if item = location.items.detect{|item| item.name.downcase == subject}
          if location.creatures.empty?
            location.items.delete(item)
            player.inventory.push(item)
            result << "have taken the #{item.name}, in all of its glory! It has been added to your pack."
          else
            result << "cannot take the glorious #{item.name} with "
            result << location.creatures.collect(&:name).en.conjunction(:generalize => true)
            result << " nearby!"
          end
        else
          "You cannot take something that doesn't exist!"
        end
      end

      look = Command.new("look")
      look.description = "You can look in different directions (north, south, east, west) or around. ex 'look around' or 'look north'"
      look.ask = "Where would you like to look?"
      look.evaluator = lambda do |subject, location, player|
        result = "You see "

        if %w(north south east west).include?(subject)
          place = location.send(subject)

          result << (place ? "the #{place.description}" : "nothing")
          result << " to the #{subject.titlecase}."
        elsif subject == "around"
          result << (location.elements.empty? ? "nothing" : location.elements.collect(&:name).en.conjunction(:generalize => true))
          result << " nearby."
        else
          result = "It would be crazy to look at that! Try looking around or to the north maybe."
        end

        result

      end

      help = Command.new("help")
      help.ask = "You can interact with the world with a number of different commands:\nlook, attack, take, drop and move\nFor more information on each command you can enter 'help {command}'"
      help.evaluator = lambda do |subject|
        command = Commands.all.detect{|c|c.name==subject}
        command ? command.description : "Sorry, we don't know that command in this world!"
      end


      [attack, take, help, look]
    end

    class Command
      extend ActiveSupport::DescendantsTracker
      attr_accessor :name, :evaluator, :description, :ask

      def initialize(name, description=nil, ask=nil, &block)
        @name = name
        @description = description if description
        @ask = ask if ask

        @evaluator = block if block_given?
      end

      def evaluate(input, game)
        input = input.strip.downcase
        match = /^#{name} (.*)$/.match(input)
        return ask unless match && match[1]
        subject = match[1].downcase

        #[0..evaluator.arity-1]
        num = evaluator.is_a?(Proc) ? evaluator.arity-1 : evaluator.method("call").arity-1
        evaluator.call(*[subject, game.current_location, game.player][0..num]) if evaluator
      end

      def handle?(input)
        /^#{name}/ =~ input.strip.downcase
      end
    end

    class InvalidCommand < StandardError
    end

    class TakeCommandEvaluator
      def call(subject, location, player)
        result = "You "
        if item = location.items.detect{|item| item.name.downcase == subject}
          if location.creatures.empty?
            location.items.delete(item)
            player.inventory.push(item)
            result << "have taken the #{item.name}, in all of its glory! It has been added to your pack."
          else
            result << "cannot take the glorious #{item.name} with "
            result << location.creatures.collect(&:name).en.conjunction(:generalize => true)
            result << " nearby!"
          end
        else
          "You cannot take something that doesn't exist!"
        end
      end
    end

    class AttackCommandEvaluator
      def call(subject, location)
        if creature = location.creatures.detect{|creature| creature.name.downcase == subject}
          location.creatures.delete(creature)
          "You attack the #{creature.name} and vanquish it!!"
        else
          "You cannot attack something that doesn't exist!"
        end
      end
    end

    class LookCommandEvaluator
      def call(subject, location, player)
        result = "You see "

        if %w(north south east west).include?(subject)
          place = location.send(subject)

          result << (place ? "the #{place.description}" : "nothing")
          result << " to the #{subject.titlecase}."
        elsif subject == "around"
          result << (location.elements.empty? ? "nothing" : location.elements.collect(&:name).en.conjunction(:generalize => true))
          result << " nearby."
        else
          result = "It would be crazy to look at that! Try looking around or to the north maybe."
        end

        result

      end
    end
  end
end

module Adventure
    # evaluates the game DSL to build the world
  class GameBuilder
    attr_reader :deferred_locations, :game

    def initialize(game)
      @game = game
      @deferred_locations = []
    end

    def place(name, &block)
      place = Place.new(name)
      PlaceBuilder.new(self, place).instance_eval(&block)

      @game.places[place.name.to_s] = place
    end

    def command(name, &block)
      command = Commands::Command.new(name)
      CommandBuilder.new(self, command).instance_eval(&block)

      @game.commands[command.name] = command
    end

    class CommandBuilder
      def initialize(builder, command)
        @builder = builder
        @command = command
      end

      def ask(value)
        @command.ask = value
      end

      def description(value)
        @command.description = value
      end

      def evaluator(evaluator)
        @command.evaluator = evaluator
      end

    end

    class PlaceBuilder

      def initialize(builder, place)
        @builder = builder
        @place = place
      end

      def player(value)
        @builder.game.current_location = @place
      end

      def description(value)
        @place.description = value
      end
      alias :desc :description

      def creature(value)
        @place.creatures << Creature.new(value)
      end

      def item(value)
        @place.items << Item.new(value)
      end

      def north(value)
        @builder.deferred_locations << [@place, value, :north]
      end

      def south(value)
        @builder.deferred_locations << [@place, value, :south]
      end

      def east(value)
        @builder.deferred_locations << [@place, value, :east]
      end

      def west(value)
        @builder.deferred_locations << [@place, value, :west]
      end
    end
  end
end

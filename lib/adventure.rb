require 'rubygems'
require 'active_support'
require 'linguistics'
Linguistics::use( :en )

require 'adventure/commands'
require 'adventure/game_builder'

module Adventure
  DID_SOMETHING_WRONG = "Whoops!! You trip over your own feet. You need to pay attention to what you are doing, it's dangerous out here!"

  class Creature
    attr_accessor :name, :inventory

    def initialize(name)
      @name = name.to_s
      @inventory = []
    end
  end

  class Item
    attr_accessor :name

    def initialize(name)
      @name = name.to_s
    end
  end

  class Place
    attr_accessor :name, :description, :creatures, :items, :north, :south, :east, :west

    def initialize(name, description="")
      @name = name
      @description = description
      @creatures = []
      @items = []
    end

    def north=(place)
      @north = place
      # reciprocate the location
      place.south = self
    end

    def elements
      creatures + items
    end
  end

  class Game
    HELP_ASK = "You can interact with the world with a number of different commands:\nlook, attack, take, drop and move\nFor more information on each command you can enter 'help {command}'"

    attr_accessor :commands, :places, :current_location
    attr_reader :player

    def initialize
      @places = {}
      @commands = {}
      @turns = 0
      @started = false

      @help_command = Commands::Command.new("help", "", HELP_ASK) do |subject|
        command = @commands.values.detect{|c|c.name==subject}

        command ? command.description : "Sorry, we don't know that command in this world!"
      end
    end

    def self.build(game_dsl, game=nil)
      # always load the default commands.
      # should find a better way to do this
      default_commands = File.read(File.expand_path("../../examples/commands", __FILE__))
      game ||= Game.new

      builder = GameBuilder.new(game)
      builder.instance_eval(game_dsl+"\n#{default_commands}")

      builder.deferred_locations.each do |place, value, direction|
        place.send("#{direction}=", game.places[value.to_s])
      end

      game
    end

    def start
      @started = true
      @player = Creature.new("Player")

      "You start out in the " + current_location.description + ". What would you like to do?"
    end

    def play(input="")
      command = (commands.values + [@help_command]) .detect do |command|
        command.handle?(input)
      end

      return DID_SOMETHING_WRONG unless command

      begin
        command.evaluate(input, self)
      rescue Adventure::Commands::InvalidCommand
        DID_SOMETHING_WRONG
      end
    end
  end

end

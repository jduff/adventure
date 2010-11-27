require 'test/unit'
require File.expand_path('../../lib/adventure.rb',__FILE__)

class TestGame < Test::Unit::TestCase

  def test_built_in_commands_build
    game = Adventure::Game.build(File.read(File.expand_path("../../examples/commands", __FILE__)))

    commands = game.commands

    assert_equal 3, game.commands.length
    assert_equal "take", game.commands["take"].name
    assert_equal "What would you like to take?", game.commands["take"].ask
    assert_equal "You can take any items that are around you, as long as there's no creatures. ex 'take knife'", game.commands["take"].description
  end

  def test_basic_game_build
    game = Adventure::Game.build(File.read(File.expand_path("../../examples/simple", __FILE__)))

    assert_equal 2, game.places.length
    assert_equal "The Forest", game.places["The Forest"].name
    assert_equal "Gloomy Forest", game.places["The Forest"].description

    assert_equal 1, game.places["The Forest"].creatures.length
    assert_equal "goblin", game.places["The Forest"].creatures[0].name

    assert_equal 1, game.places["The Forest"].items.length
    assert_equal "knife", game.places["The Forest"].items[0].name


    # Second Place
    assert_equal "Open Road", game.places["Open Road"].name

    # Directions
    assert_equal game.places["Open Road"], game.places["The Forest"].north
    assert_equal game.places["The Forest"], game.places["Open Road"].south

    # Player location
    assert_equal game.places["The Forest"], game.current_location

    # Playing
    assert_equal "You start out in the Gloomy Forest. What would you like to do?", game.start

    # Help
    assert_equal "You can interact with the world with a number of different commands:\nlook, attack, take, drop and move\nFor more information on each command you can enter 'help {command}'", game.play("help")
    assert_equal "You can look in different directions (north, south, east, west) or around. ex 'look around' or 'look north'", game.play("help look")
    assert_equal "Sorry, we don't know that command in this world!", game.play("help robots")

    # Looking
    assert_equal "Where would you like to look?", game.play("look")
    assert_equal "You see the Open Road to the North.", game.play("look north")
    assert_equal "You see nothing to the South.", game.play("look south")
    assert_equal "You see a goblin and a knife nearby.", game.play("look around")

    # Taking
    assert_equal "What would you like to take?", game.play("take")
    assert_equal "You cannot take the glorious knife with a goblin nearby!", game.play("take knife")

    # Attacking
    assert_equal 1, game.current_location.creatures.length
    assert_equal "What would you like to attack?", game.play("attack")
    assert_equal "You cannot attack something that doesn't exist!", game.play("attack hairbrush")
    assert_equal "You attack the goblin and vanquish it!!", game.play("attack goblin")
    assert_equal 0, game.current_location.creatures.length

    # Taking
    assert_equal 1, game.current_location.items.length
    assert_equal "You have taken the knife, in all of its glory! It has been added to your pack.", game.play("take knife")
    assert_equal 0, game.current_location.items.length
    assert_equal 1, game.player.inventory.length
    assert_equal "knife", game.player.inventory[0].name

    # Moving

    
  end
end

require 'tty-prompt'
class CLI 

    def array_all_pokemon_i_can_evolve
        @current_user.array_which_pokemons_can_i_evolve
    end

    def array_all_my_pokemon
        arr = Array.new
        @current_user.see_all_my_pokemon_with_id.each {|e| arr.push(e[:name])}
        arr
    end

    def opening_credits
        ASCII.opening_credits_image
    end

    $prompt = TTY::Prompt.new

    def greet_user
        choice = $prompt.select("Hi trainer, please select the option you'd like:", ["Log In", "Create Account", "Exit"])
        if choice == "Log In"
            login
        elsif choice == "Create Account"

            check_username_available
        else
            exit_app
        end
    end

    # abstract out check username valid
    def check_username
        @response = $prompt.ask("Please enter a username => ", required: true).capitalize
        User.find_by(username: @response)
    end

    # use check_username to check validity
    # if it is valid, commence login,
    # otherwise ask again.
    def login
        user = check_username
        if user
            @current_user = user
            puts ""
            puts "Hi #{@current_user.username}! Welcome back trainer!"
            main_menu
        else 
            choice = $prompt.select("That username doesn't exist, would you like to create an account?", ["Yes", "No, return to start"])
            if choice == "Yes"
                check_username_available
            else
                greet_user
            end
        end
    end

    def logout_app
        option = $prompt.select("Are you sure you want to logout?",["Yes, see you later, Feraligatr","Not right now"])
        sleep(0.9)
        if option == "Yes, see you later, Feraligatr"
            ASCII.totodile
            puts " ---------------------------------------------------------------------------------------------"
            puts "|                                     In a while Totodile                                     |"
            puts " ---------------------------------------------------------------------------------------------"
            sleep(1.5)
            opening_credits
            greet_user
        else
            main_menu
        end
    end

    def check_username_available
        @user = check_username
        if @user
            option = $prompt.select("Sorry, that username is already taken!",["1: Try a different username","2: Take me to Login", "3: Exit"])
            if option == "1: Try a different username"
                sleep(0.1)
                check_username_available
            elsif option == "2: Take me to Login"
                sleep(0.1)
                login
            else
                exit_app
            end
        else
            set_up_account
        end
    end

    def set_up_account
        puts ""
        puts "Setting up account:"
        @current_user = User.new(username:@response)
        candy_set = $prompt.ask("How many candies do you have?", required: true) do |q|
                q.validate(/^-?[0-9]+$/, "Invalid input, please type a number")
            end
        @current_user.candies = candy_set
        @current_user.save
        puts ""
        puts "Welcome #{@response}, you have created an account with #{candy_set} candies."
        import_choice = $prompt.select("Do you have any existing Pokémon to import?", ["Yes","No"])
        puts ""
        if import_choice == "Yes"
            import_existing_pokemon
        end
        sleep(0.2)
        main_menu
    end

    def import_existing_pokemon
        poke_name = $prompt.ask("Please input Pokémon name => ", required: true).capitalize
        if PokemonFamily.find_pokemon_family_by_name(poke_name)
            @current_user.import_pokemon(poke_name)
            puts "#{poke_name} added to your list!"
            import_choice = $prompt.select("Would you like to add another one?", ["Yes","No"])
            if import_choice == "Yes"
                import_existing_pokemon
            end
        else
            import_choice = $prompt.select("Try again?", ["Yes","No, return to main menu"])
            if import_choice == "Yes"
                import_existing_pokemon
            end
        end
    end

    def main_menu
        puts ""
        choice = $prompt.select("What would you like to do?", ["1: Catch Pokémon", "2: See all of my Pokémon", 
            "3: See how many candies I have", "4: See which Pokémon I can evolve", "5: Send a Pokémon to the Professor", "6: Logout", "7: Exit"])
        if choice == "1: Catch Pokémon"
            catch_pokemon_name
        elsif choice == "2: See all of my Pokémon"
            see_my_pokemon 
        elsif choice == "3: See how many candies I have"
            puts ""
             p "You have #{@current_user.see_my_candies} candies."
             sleep(1)
             return_main_menu
        elsif choice == "4: See which Pokémon I can evolve" 
            see_wich_pokemon_can_i_evolve
        elsif choice == "5: Send a Pokémon to the Professor"
            send_pokemon_to_professor
        elsif choice == "6: Logout"
            logout_app
        else
            exit_app
        end
        puts ""
    end

    def return_main_menu
        choice = $prompt.select("What would you like to do now?", ["Return to main menu", "Exit"])
        if choice == "Return to main menu"
            main_menu
        else
            exit_app
        end
    end

    def catch_pokemon_name
        puts ""
        poke_name = $prompt.ask("Please enter Pokémon name => ", required: true).capitalize
        if PokemonFamily.find_pokemon_family_by_name(poke_name)
            @current_user.catch_pokemon(poke_name)
            puts ""
            puts "Nice, you caught a #{poke_name}!"
            puts "You now have #{@current_user.candies} candies."
            sleep(0.5)
            return_main_menu
        else
            choice = $prompt.select("Would you like to try again?", ["Yes please", "Not right now, take me back to the main menu"])
            if choice == "Yes please"
                catch_pokemon_name
            else
            sleep(0.5)
            return_main_menu
            end
        end
        puts ""
        sleep(0.5)
        return_main_menu
    end


    def can_i_evolve_pokemon_by_name ####### it's working
        puts ""
        pokemon_array = @current_user.array_which_pokemons_can_i_evolve
        poke_evol = $prompt.select("Which Pokémon would you like to evolve now??", Array[pokemon_array])
        puts ""
        puts "You have enough candies to evolve your #{poke_evol}."
        choice = $prompt.select("Would you like to evolve this Pokémon now?", ["Hell yeah!", "Not right now"])
            if choice == "Hell yeah!"
                @current_user.evolve_and_change_name_by_name(poke_evol)
                puts "You still have #{@current_user.candies} candies left!"
            end 
        puts ""   
    end

    # def evolve_pokemon_with_id
    #     pokemon_id = $prompt.ask("Please enter Pokémon id => ").to_i
    #     puts "You are about to evolve #{Pokemon.find_name_by_id(pokemon_id)} for #{Pokemon.find(pokemon_id).my_candies_to_evolve} candies"
    #     choice = $prompt.select("Are you sure?", ["Yeah, let's evolve!", "Not right now"])
    #     if choice == "Yeah, let's evolve!"
    #         @current_user.evolve_and_change_name(pokemon_id)
    #         puts "You still have #{@current_user.candies} candies left!"
    #     end
    #     sleep(1)
    #     return_main_menu
    # end

    def see_my_pokemon
        if !@current_user.all_my_pokemon.empty?
            @current_user.see_all_my_pokemon_with_id.each { |poke| puts "#{poke[:name]}" }
        else
            puts ""
            puts "Oh no, it doesn't seem you have any Pokémon, try catch them all"
        end   
        sleep(1)
        return_main_menu
    end

    def see_wich_pokemon_can_i_evolve
        puts ""
        puts "-----You currently have #{@current_user.candies} candies-----"
        if !@current_user.array_which_pokemons_can_i_evolve.empty?
            @current_user.array_which_pokemons_can_i_evolve.each { |poke| puts "#{poke}"} #had to delete the candies to evolve
            choice = $prompt.select("Would you like to evolve a Pokémon now?", ["Yeah, let's evolve!", "Not right now"])
                if choice == "Yeah, let's evolve!"
                    can_i_evolve_pokemon_by_name
                end
        else
            puts ""
            puts "Oh no, it seems you don't have any Pokémon that you can evolve right now, try catching some."
        end
        sleep(0.2)
        return_main_menu
    end

    def send_pokemon_to_professor
        puts ""
        if !@current_user.all_my_pokemon.empty?
            send_away = $prompt.select("Who would you like to send to the professor?", Array[array_all_my_pokemon])
            puts ""
            puts "You are about to send #{send_away} to the professor."
            choice = $prompt.select("This can't be undone, are you sure?", ["Yes, send it to the professor", "No I'll hang on to it"])
            if choice == "Yes, send it to the professor"
                puts ""
                @current_user.delete_pokemon_by_name(send_away)
                puts "Your Pokémon is now with the professor, he sent you a candy in return."
                puts "You now have #{@current_user.candies} candies."
                puts ""
            end
        else
            puts ""
            puts "Oh no, it doesn't seem you have any Pokémon, try catch them all"
        end
        sleep(0.2)
        return_main_menu
    end


    def exit_app
        puts "Goodbye, thanks for using"
        sleep(0.2)
        ASCII.small_logo
        sleep(1)
    end

    
    

# write methods above here
end

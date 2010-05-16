--[[

   MISSION: Defend the System 1
   DESCRIPTION: A mission to defend the system against swarm of pirate ships.
                This will be the first in a planned series of random encounters.
                After the third specifically scripted pirate invasion, a militia will form.
                The player will have the option to join the militia.
                Perhaps the random missions will eventually lead on to a plot line relating to the pirates.

      Notable events:

         * Stage one: From the bar, the player learns of a pirate fleet attacking the system and joins a defense force.
         * Stage two: The volunteer force attacks the pirates.
         * Stage three: When a sufficient number have been killed, the pirates retreat.
         * Stage four: The portmaster welcomes the fleet back and thanks them with money.
         * Stage five: In the bar afterward, another pilot wonders why the pirates behaved unusually.

TO DO
Make comm chatter appear during the battle
Add some consequences if the player aborts the mission
]]--

-- localization stuff, translators would work here
lang = naev.lang()
if lang == "es" then
else -- default english

-- This section stores the strings (text) for the mission.

-- Mission details
   misn_title = "Defend the System"
   misn_reward = "%d credits and the pleasure of serving the Empire."
   misn_desc = "Defend the system against a pirate fleet."

-- Stage one: in the bar you hear a fleet of Pirates have invaded the system.
   title = {}
   text = {}
   title[1] = "In the bar"
   text[1] = [[The bar is buzzing when you walk in. All the pilots are talking at once. Every screen in sight carries the same news feed: live footage of a space battle in orbit around %s.

"A big fleet of pirates have just invaded the system," a woman wearing a Nexus insignia explains. "They swarm any ship that tries to take off. Shipping is at a standstill. It's a disaster."

There's a shout and you turn to see the portmaster standing at the door. "Listen up," he bellows. "The thugs out there have caught us without a defense fleet in system and somehow they've jammed our link with the rest of the Empire. So, I'm here looking for volunteers. Everyone who steps forward will get forty thousand credits when they get back and of course the thanks of a grateful planet and the pride of serving the Empire.

"Are you brave enough?"]]
   title[11] = "Volunteers"
   text[11] = [[You step forward and eight other pilots join you. Together, all of you march off to the your ships and take off to face the pirate horde.]]

-- Stage two: Vicious comm chatter
   comm = {}
   comm[1] = "Eat vacuum, scum!"
   comm[2] = "Die, pirate, die."
   comm[3] = "Eat cannon fire"
   comm[4] = "Thieving parasites"
   comm[5] = "I've got one on me!"

-- Stage three: Victorious comm chatter
   comm[6] = "That's right, run away you cowards."
   comm[7] = "Good job, everyone. Let's get back planetside and get our reward."

-- Stage four: the portmaster greets you when you return to the planet
   title[2] = "Welcome back"
   text[2] = [[The portmaster greets the crowd of volunteers on the spaceport causeway.

"Well done. You got those pirates on the run!"  He exclaims. "Maybe they'll think twice now before bothering our peace. I hope you all feel proud. You've spared this planet millions in shipping, and saved countless lives. And you've earned a reward. Before you takeoff today, the port authority will give you each forty thousand credits. Congratulations!"

Your comrades raise a cheer everyone shakes the postmasters hand. One of them kisses the master on both cheeks in the Goddard style, then the whole crowd moves toward the bar.]]

-- Stage five: talking afterward in the bar
   title[3] = "Over drinks"
   text[3] = [[Many hours later, the celebration has wound down. You find yourself drinking with a small group of 'veterans of the battle of %s,' as some of them are calling it. A older pilot sits across the table and stares pensively into his drink.

"It's strange, though," he mutters. "I've never seen pirates swarm like that before."]]

-- Other text for the mission
   comm[8] = "You fled battle. The Empire wont forget."
   comm[9] = "Comm Trader>You're a coward, %s. You better hope I never see you again."
   comm[10] = "Comm Trader>You're running away now, %s? The fight's finished, you know..."
   title[4] = "Good job"
   text[4] = [[You jump out of %s the sweat still running down your face. The fight to clear the system was brief but intense. After a moment, another ship enters on the same vector. The blast marks on the sides of his craft show it too comes from combat with the pirates. Your comm beeps.

"Good flying, mate. We got those pirates on the run!"  The pilot exclaims. "You didn't want to go back for the cash either, eh?  I don't blame you. I hate pirates, but I don't want the Empire's money!"  He smiles grimly. "It's strange, though. I've never seen pirates swarm that way before."
]]
   title[5] = "Left behind"
   text[5] = [[Eight pilots step forward. The rest of you stand and watch as they file out the door. The portmaster spares a withering glance for those left behind.

"Don't get your petticoats caught in the crossfire on your way out of atmo," he sneers. Then he turns to follow his volunteers.]]
   bounce_title = "Not done yet."
   bounce_text = "The system isn't safe yet. Get back out there!"
   noReward = "No reward for you."
   noDesc = "Watch others defend the system."
   noTitle = "Watch the action."

end 


-- Create the mission on the current planet, and present the first Bar text.
function create ()

      this_planet, this_system = planet.cur()
      if ( this_system:hasPresence( "Pirate" ) or 
           this_system:hasPresence( "Collective" ) or 
           this_system:hasPresence( "FLF" ) ) 
         then misn.finish(false) 
      end
      planet_name = this_planet:name()
      system_name = this_system:name()
      if tk.yesno( title[1], string.format( text[1], planet_name ) ) then
         misn.accept()
         var.push( "dts_firstSystem", "planet_name")
         tk.msg( title[11], text[11])
         reward = 40000
         misn.setReward( string.format( misn_reward, reward) )
         misn.setDesc( misn_desc)
         misn.setTitle( misn_title)
         misn.setMarker( this_system, "misc" )
         defender = true

     -- hook an abstract deciding function to player entering a system
         hook.enter( "enter_system")

     -- hook warm reception to player landing
         hook.land( "celebrate_victory")
      
      else
     -- If player didn't accept the mission, the battle's still on, but player has no stake.
         misn.accept()
         var.push( "dts_firstSystem", "planet_name")
         tk.msg( title[5], text[5])
         misn.setReward( noReward)
         misn.setDesc( noDesc)
         misn.setTitle( noTitle)
         defender = false
         
     -- hook an abstract deciding function to player entering a system when not part of defense
         hook.enter( "enter_system")
      end

end

-- Decides what to do when player either takes off starting planet or jumps into another system
function enter_system()

      if this_system == system.get() and defender == true then
         defend_system()
      elseif victory == true and defender == true then
         misn.timerStart( "ship_enters", 1000)
      elseif defender == true then
         player.msg( comm[8])
         player.modFaction( "Empire", -3)
         misn.finish( true)
      elseif this_system == system.get() and been_here_before ~= true then
         been_here_before = true
         defend_system()
      else
         misn.finish( true)
      end
end

-- There's a battle to defend the system
function defend_system()

  -- Makes the system empty except for the two fleets. No help coming.
      pilot.clear ()
      pilot.toggleSpawn( false )

  -- Set up distances
      angle = rnd.rnd() * 2 * math.pi
      if defender == true then
         raider_position  = vec2.new( 400*math.cos(angle), 400*math.sin(angle) )
         defense_position = vec2.new( 0, 0 )
      else
         raider_position  = vec2.new( 800*math.cos(angle), 800*math.sin(angle) )
         defense_position = vec2.new( 400*math.cos(angle), 400*math.sin(angle) )
      end

  -- Create a fleet of raiding pirates
      raider_fleet = pilot.add( "DTS Raiders", "def", raider_position )
      for k,v in ipairs( raider_fleet) do
         pilot.setHostile( v)
      end

  -- And a fleet of defending independents
      defense_fleet = pilot.add( "DTS Defense Fleet", "def", defense_position )
      for k,v in ipairs( defense_fleet) do
         pilot.setFriendly( v)
      end

  --[[ How the Battle ends:
    hook fleet departure to disabling or killing ships]]
      casualties = 0
      for k, v in ipairs( raider_fleet) do
         hook.pilot (v, "death", "add_cas_and_check")
         hook.pilot (v, "disable", "add_cas_and_check")
      end

      if defender == false then
         misn.finish( true)
      end
      
      if pilot.get( "Raider") == {} then
         player.msg( comm[7])
      end

end

-- Record each raider death and make the raiders flee after too many casualties
function add_cas_and_check()

      casualties = casualties + 1
      if casualties > 8 then

         raiders_left = pilot.get( { faction.get("Raider") } )
         for k, v in ipairs( raiders_left ) do
            pilot.changeAI( v, "flee")
         end
         if victory ~= true then   -- A few seconds after the raiders start to flee declare victory
            victory = true
            player.msg( comm[6])
            misn.timerStart( "victorious", 8000)
         end
      end

end

-- Call ships back to base
function victorious()

      player.msg( comm[7])

end

-- The player lands to a warm welcome (if the job is done).
function celebrate_victory()

      if victory == true then
         tk.msg( title[2], string.format( text[2], planet_name ) )
         player.pay( reward)
         player.modFaction( "Empire", 3)
         tk.msg( title[3], string.format( text[3], system_name) )
         misn.finish( true)
      else
         tk.msg( bounce_title, bounce_text)   -- If any pirates still alive, send player back out.
         player.takeoff()
      end

end

-- A fellow warrior says hello in passing if player jumps out of the system without landing
function ship_enters()

      enter_vect = player.pos()
      pilot.add("Trader Mule", "def", enter_vect:add( 10, 10), true)
      misn.timerStart( "congratulations", 1000)
end
function congratulations()
      tk.msg( title[4], string.format( text[4], system_name))
      misn.finish( true)

end

function abort()

      if victory ~= true then
         player.modFaction( "Empire", -10)
         player.modFaction( "Trader", -10)
         player.msg( string.format( comm[9], player.name()) )
      else
         player.msg( string.format( comm[10], player.name()) )
      end

end

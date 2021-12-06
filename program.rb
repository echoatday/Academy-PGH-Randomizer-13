# credit to LagoLunatic's Wind Waker Randomizer for the original adjective and noun lists
# check it out here: https://github.com/LagoLunatic/wwrando
# otherwise made by echo, steal if u want


def shoveler(input)
    print input
    @clipboard << input                         # instead of just printing things, we're going to print them AND ALSO shovel them into the clipboard
end

def clear
    system("cls") || system("clear")            # clear console method
end

def randomizer(input)
    return rand(input.length).to_i              # just a randomizer (:
end

def printer(input)
    selection = input[ randomizer(input) ]      # select a random entry in the array
    shoveler(" " + selection.capitalize)        # print selection out, capitalized
    return input - [selection]                  # delete selection from the array on return
end


# Setting Up Arrays. Removing Absentees and Declaring 1-on-1s.
# ==========================================================================================================================================================


#populate arrays with the file contents split by lines
studList = File.open("students.txt").readlines.map(&:chomp)
teacList = File.open("teachers.txt").readlines.map(&:chomp)
meetList = {}


absent = ""
# let's mark TAs and students as absent just in case
while absent != "Done"
    clear
    puts "[=STUDENTS=]"
    puts studList
    puts
    puts "[=TEACHERS=]"
    puts teacList
    puts
    puts "Please enter absent students and teachers one at a time. Enter 'done' to continue."
    absent = gets.chomp.capitalize
    studList = studList - [absent]
    teacList = teacList - [absent]
end

# clone new list so we can empty one out then reset
teacRecord = teacList.map(&:clone)

clear
puts "Will there be 1-on-1s during group work? Answer Y/N"
meetingCheck = gets.chomp.upcase

absent = ""
# now let's move the 1-on-1s to a new array, using 'absent' again just for convenience
while teacList.length > 0 and meetingCheck == "Y"
    clear
    puts "[=STUDENTS=]"
    puts studList
    puts
    puts "[=1-ON-1S=]"
    puts meetList
    puts
    puts "Please enter the student scheduled for a 1-on-1 with #{teacList[0]}."
    absent = gets.chomp.capitalize
    if studList.include?(absent)
        meetList[ teacList.delete_at(0) ] = studList.delete(absent)
    end
end

# more clones. the hash is converted into a byte stream during the copy, then back out. this ensures a deep copy
studRecord = studList.map(&:clone)
meetRecord = Marshal.load(Marshal.dump(meetList))


# Generation of Randomized Output
# ==========================================================================================================================================================


r = ""
while r == ""
    # magic instanced variable that stores stuff to be sent to the OS clipboard
    @clipboard = ""

    #lists to be reset on loop
    adjeList = File.open("adjectives.txt").readlines.map(&:chomp)
    nounList = File.open("nouns.txt").readlines.map(&:chomp)
    teamList = File.open("teams.txt").readlines.map(&:chomp)
    studList = studRecord.map(&:clone)
    teacList = teacRecord.map(&:clone)
    meetList = Marshal.load(Marshal.dump(meetRecord))

    #set team size
    teamNumber = teacList.length
    team = 0
    #clear the screen
    clear

    #print teams
    while teamNumber > 0

        #assign team numbers
        team += 1
        shoveler("[========================TEAM=#{team}=]")
        shoveler("\n")


        # recalculate size of team based on students that remain
        teamSize = (studList.length + meetList.length) / teamNumber

        #assign team names
        adjeList = printer(adjeList)
        nounList = printer(nounList)
        teamList = printer(teamList)
        shoveler("\n\n")

        # the teacher of the current group
        currentTeac = teacList[team-1]

        #assign the teacher without randomizing
        shoveler("                         ")
        shoveler(currentTeac)
        teacList -= [teamNumber]
        shoveler("\n")

        if meetingCheck == "Y"
            #assign 1-on-1 student without randomizing 
            shoveler("-")
            shoveler(meetList[currentTeac])
            meetList.delete(currentTeac)
            shoveler("\n")
            memberCounter = 1
        else
            memberCounter = 0
        end

        #assign team members
        while memberCounter < teamSize
            studList = printer(studList)
            shoveler("\n")
            memberCounter += 1
        end
        shoveler("\n")

        teamNumber -= 1
    end

    # copy to OS clipboard time

    # windows
    IO.popen('clip', 'w') { |pipe| pipe.puts @clipboard }
    # mac
    # IO.popen('pbcopy', 'w') { |pipe| pipe.puts $clipboard }

    puts "This output has been copied to your clipboard automatically."
    puts "Press enter to re-randomize, or enter any string to quit."
    r = gets.chomp.downcase
end
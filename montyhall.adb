with Ada.Text_IO; use Ada.Text_IO;
with Ada.Text_IO, Ada.Integer_Text_IO;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
--with ada.numerics.discrete_random;
with ada.numerics.float_random; use ada.numerics.float_random;

procedure Montyhall is

    ----------------------------------------------------------------------------

    times_switched : Integer := 0;          --count of times programm switched doors
    times_correct_switched : Integer := 0;  --count of times the program was correct when switching doors
    times_correct_unchanged : Integer := 0; --count of times the program was correct when not switching doors
    switched_percent : float := 0.0;          --Value to hold percent value representing how likely you are to get the correct guess when switching doors
    unchanged_percent : float := 0.0;         --Value to hold percent value representing how likely you are to get the correct guess without switching doors

    test_cases : Integer := 0;              --How many times program ran the test

    selected_door : Integer := 0;           --Door Selected By the User
    dud_door : Integer := 0;                --Door with nothing behind it revealed to program
    prize_door : Integer := 0;              --Door Containing the pirze


    ----------------------------------------------------------------------------

    type Door;
    type ref_Door is access Door;
    type Door is record
        Number : Integer;
        Contains_Prize : Boolean;
        Back : ref_Door := null;
        Next : ref_Door := null;
    end record;

    ----------------------------------------------------------------------------

    type Door_List is record
        Head: ref_Door;
        Tail: ref_Door;
    end record;
    doors : Door_List;

    ----------------------------------------------------------------------------

    procedure Insert_Door(door_num : Integer; contains_prize : Boolean; doors: in out Door_List) is
    begin
        if doors.Head = null then
            doors.Head := new Door'(door_num, contains_prize, null, null);
            doors.Tail := doors.Head;
            --Put_Line("Doors Created");
        else
            doors.Tail.Next := new Door'(door_num, contains_prize, doors.Tail, null);
            doors.Tail := doors.Tail.Next;
            --Put_Line("Door Added to Doors");
        end if;

    end Insert_Door;

    ----------------------------------------------------------------------------

    function Generate_Random_Number(num_start, num_end : Integer) return Integer Is

        randRange : Integer := num_end - num_start;
        gen : Generator;
        num : float;
    begin
        reset(gen);
        num := random(gen);
        num := float(randRange) * num + float(num_start);

      --Put_Line(Float'Image(num));

      if Integer(num) > 3 then
         return 3;

      elsif Integer(num) < 1 then
         return 1;
      else
         return Integer(num);
      end if;


    end Generate_Random_Number;

    ----------------------------------------------------------------------------

    procedure Create_Doors(doors: in out Door_List) Is
        prize_set : Boolean := False;
    begin
        for i in 1 .. 3 loop

            if prize_set = False then
                if i = 3 then
                    Insert_Door(i, True, doors);
                    prize_door := i;
                    --Put_Line("Prize Set at Door: " & Integer'Image (i));

                elsif Generate_Random_Number(0, 1) = 1 then
                    Insert_Door(i, True, doors);
                    prize_set := True;
                    prize_door := i;
                    --Put_Line("Prize Set at Door: " & Integer'Image (i));

                else
                    Insert_Door(i, False, doors);

                end if;

            else
                Insert_Door(i, False, doors);
            end if;
        end loop;

        --Put_Line("Doors Created");
    end Create_Doors;

    ----------------------------------------------------------------------------

    function Reveal_Empty_Door(selected_door: in Integer; doors: in Door_List) return Integer is
        current_door : ref_door := doors.Head;
        run : Boolean := True;
    begin

        while run = True loop
            if current_door.Contains_Prize = False and current_door.Number /= selected_door then

                --Put_Line("Dud door at: " & Integer'Image (current_door.Number));
                return current_door.Number;

            elsif current_door.Next = null then
                run := False;
            end if;

            current_door := current_door.Next;
        end loop;

        return -1;

    end Reveal_Empty_Door;

    ----------------------------------------------------------------------------

    procedure Change_Door(selected_door: in out Integer; dud_door: in Integer) is
        run : Boolean := True;
        changed_door : Integer;
    begin
        while run = True loop

            changed_door := Generate_Random_Number(1,3);

            if changed_door /= selected_door and changed_door /= dud_door then
                selected_door := changed_door;
                run := False;
            end if;
        end loop;
    end Change_Door;

    ----------------------------------------------------------------------------

    function Check_Answer(selected_door: in Integer; doors: in Door_List) return Boolean is
        current_door : ref_door := doors.Head;
        run : Boolean := True;
    begin

        while run = True loop

            if current_door.Number = selected_door Then
                return current_door.Contains_Prize;
            else
                current_door := current_door.Next;
            end if;

            if current_door = null then
                run := False;
            end if;

        end loop;

        return False;

    end Check_Answer;

    ----------------------------------------------------------------------------

    procedure Clear_Fields(doors: in out Door_List) is
        current_door : ref_door := doors.Head;
        next_door : ref_door;
    begin
        --selected_door := null;
        --dud_door := null;
        --prize_door := null;

        while current_door /= null loop
            next_door := current_door.Next;

            current_door.Next := null;
            current_door.Back := null;
            --current_door.Number := null;
            --current_door.Contains_Prize := null;

            current_door := next_door;

        end loop;


    end Clear_Fields;

    ----------------------------------------------------------------------------
begin

    --Change number of test cases here:
    test_cases := 1000;

    for i in 1 .. test_cases loop

        Create_Doors(doors);

        selected_door := Generate_Random_Number(1,3);

        dud_door := Reveal_Empty_Door(selected_door, doors);

        --For the first half dont change doors
        --For the second half, do
        if i > (test_cases / 2) then
            Change_door(selected_door, dud_door);

            if Check_Answer(selected_door, doors) = True Then
                --Put_Line("Correct Door Selected");
                times_correct_switched := times_correct_switched + 1;
            end if;

        else

            if Check_Answer(selected_door, doors) = True Then
                --Put_Line("Correct Door Selected");
                times_correct_unchanged := times_correct_unchanged + 1;
            end if;

        end if;

        Clear_Fields(doors);
    end loop;

    switched_percent := Float(times_correct_switched) / Float(test_cases / 2) * 100.0;
    unchanged_percent := Float(times_correct_unchanged) / Float(test_cases / 2) * 100.0;

    Put_Line("Each scenario was performed: " & Float'Image(Float(test_cases / 2)));
    Put_Line("");

    Put_Line("Times Correct Without Switching: " & Integer'Image(times_correct_unchanged));
    Put_Line("");

    Put_Line("Times Correct Switching: " & Integer'Image(times_correct_switched));
    Put_Line("");

    Put_Line("Not switching doors had a " & Float'Image(unchanged_percent) &
               "% of getting the prize.");
    Put_Line("");

    Put_Line("Switching door had a " & Float'Image(switched_percent) &
               "% of getting the prize.");
    Put_Line("");


end Montyhall;

welcome :-
    write('This is a prolog implementation of a knapsack problem.'),
    nl,
    write('There are n items. Each has some weight and some value. You have a knapsack of some capacity.'),
    nl,
    write('Your goal is to put some items into a knapsack maximizing the sum value of them.'),
    nl,
    write('In this implementation all numbers should be non-negative integers, also the capacity should be rather small.'),
    nl.

read_int(N, Comment) :-
    write(Comment),
    nl,
    read(Input),
    (integer(Input), Input >= 0 -> write('OK. Integer read'),nl, N = Input;
    write('Incorrect format. Should be a non-negative integer.'), nl, read_int(N, Comment)).

read_array(0, []) :- !.
read_array(N, [Head|Tail]) :-
    N > 0,
    read_int(Head, ''),
    N1 is N - 1,
    read_array(N1, Tail).

init_array(0, []) :- !.
init_array(N, [0|Tail]) :-
    N > 0,
    N1 is N - 1,
    init_array(N1, Tail).



next_state(Item, TotalWeight, Cap, NextItem, NextTotalWeight) :-
    (   TotalWeight < Cap ->
    		NextItem is Item,
        	NextTotalWeight is TotalWeight + 1;
    	NextItem is Item + 1,
        NextTotalWeight = 0).

dp_transition(Item, TotalWeight, DpTail, ForRecoveryT, DpRes, RecoveryRes, N, Cap, Weights, Values) :-
    (Item =:= N -> !, DpRes = DpTail, RecoveryRes = ForRecoveryT;
    nth0(Item, Weights, ConsiderWeight),
    nth0(Item, Values, ConsiderValue),
    dp_step(TotalWeight, ConsiderWeight, ConsiderValue, Cap, DpHead, ForRecoveryH, DpTail),
    next_state(Item, TotalWeight, Cap, NextItem, NextTotalWeight),
    dp_transition(NextItem, NextTotalWeight, [DpHead|DpTail], [ForRecoveryH|ForRecoveryT], DpRes, RecoveryRes, N, Cap, Weights, Values)).

dp_step(TotalWeight, ConsiderWeight, ConsiderValue, Cap, OptimalValue, Take, Dp) :-

    (ConsiderWeight =< TotalWeight ->
    nth0(Cap, Dp, ValueNotTake),
    Cap2 is Cap + ConsiderWeight,
    nth0(Cap2, Dp, Val),
    ValueTake is Val + ConsiderValue,
    (   ValueNotTake > ValueTake ->  OptimalValue is ValueNotTake, Take = false;
    OptimalValue is ValueTake, Take = true)

    ;  nth0(Cap, Dp, OptimalValue), Take = false).


recover(Item, Ind, Recovery, Weights, Acc, Res, Cap) :-
    (Item < 0 -> Res = Acc, !;
    nth0(Ind, Recovery, Take),
    (Take -> nth0(Item, Weights, W),
    NewInd is Ind + Cap + 1 + W,
    Item1 is Item - 1,
    recover(Item1, NewInd, Recovery, Weights, [Item|Acc], Res, Cap)
    ;
    NewInd is Ind + Cap + 1,
    Item1 is Item - 1,
    recover(Item1, NewInd, Recovery, Weights, Acc, Res, Cap)
    )).

output_array_plus_one(0, []) :- !.
output_array_plus_one(N, [Head|Tail]) :-
    N > 0,
    Out is Head + 1,
    N1 is N - 1,
    write(Out), write(' '),
    output_array_plus_one(N1, Tail).

solve(N, Cap, Weights, Values, OptimalValue, Items) :-
    Cap1 is Cap + 1,
    init_array(Cap1, Dp),
    dp_transition(0,0,Dp,[],DpRes,Recovery,N,Cap,Weights,Values),
    nth0(0, DpRes, OptimalValue),
    N1 is N - 1,
    recover(N1, 0, Recovery, Weights, [], Items, Cap).

userinput :-
    welcome,
    read_int(N, 'Please enter the number of items.'),
    read_int(Cap, 'Please enter the capacity of a knapsack.'),
	write('Please enter weights of items'),
	nl,
	read_array(N, Weights),
    write('Please enter values of items'),
    read_array(N, Values),
    solve(N, Cap, Weights, Values, OptimalValue, Items),
    write('Maximum total value is: '),
    write(OptimalValue), nl,
    write('You should take the following items: '),
    length(Items, Len),
    output_array_plus_one(Len, Items).

test :-
    findall(TestNum, test_data(TestNum, _, _, _, _, _), TestNums),
    length(TestNums, TotalTests),
    test_all(TestNums, 0, TotalPassed),
    write('Passed '), write(TotalPassed), write(' out of '), write(TotalTests).

sum_values(0, [], _, Acc, Acc):- !.
sum_values(N, [Head|Tail], Values, Res, Acc) :-
    N > 0,
    nth0(Head, Values, V),
    Res1 is Res + V,
    N1 is N - 1,
    sum_values(N1, Tail, Values, Res1, Acc).

test_all([], TotalPassed, TotalPassed).
test_all([TestNum|Tail], Passed, TotalPassed) :-
    test_data(TestNum, N, Cap, Weights, Values, Optimal),
    solve(N, Cap, Weights, Values, OptimalValue, Items),
    write('Test '), write(TestNum), write(': '),
    (OptimalValue =:= Optimal ->
    write('correct optimal value, '),
    length(Items, NumOfItems),
    sum_values(NumOfItems, Items, Values, 0, Sum),
    (Sum =:= Optimal -> write('correct recovery.'), nl,
    Passed1 is Passed + 1, test_all(Tail, Passed1, TotalPassed);
    write('incorrect recovery.'), nl, test_all(Tail, Passed, TotalPassed))
    ; write('incorrect optimal value.'),nl, test_all(Tail, Passed, TotalPassed)).

test_data(0, N, Cap, Weights, Values, Optimal) :-
    N = 2,
    Cap = 3,
    Weights = [2,2],
    Values = [1,2],
    Optimal = 2.

test_data(1, N, Cap, Weights, Values, Optimal) :-
    N = 3,
    Cap = 4,
    Weights = [1,2,3],
    Values = [10,15,40],
    Optimal = 50.

test_data(2, N, Cap, Weights, Values, Optimal) :-
    N = 2,
    Cap = 1,
    Weights = [2, 2],
    Values = [10, 20],
    Optimal = 0.

test_data(3, N, Cap, Weights, Values, Optimal) :-
    N = 50,
    Cap = 427,
    Weights = [4, 1, 9, 8, 8, 5, 4, 18, 3, 19, 14, 2, 1, 3, 7, 8, 17, 20, 1, 18, 7, 18, 14, 8, 15, 19, 9, 1, 6, 14, 11, 9, 5, 7, 11, 4, 3, 13, 4, 12, 12, 20, 9, 2, 15, 18, 4, 13, 3, 18],
    Values = [38, 81, 80, 47, 74, 25, 91, 9, 6, 85, 30, 99, 38, 11, 30, 13, 49, 36, 59, 82, 47, 21, 48, 46, 27, 86, 35, 90, 88, 83, 10, 78, 82, 22, 69, 94, 32, 21, 60, 49, 35, 82, 89, 72, 29, 88, 42, 99, 100, 8],
    Optimal = 2688.

test_data(4, N, Cap, Weights, Values, Optimal) :-
    N = 50,
    Cap = 217,
    Weights = [2, 11, 13, 9, 3, 7, 19, 11, 7, 16, 13, 15, 5, 9, 5, 8, 18, 18, 9, 19, 14, 19, 13, 12, 8, 5, 17, 16, 3, 2, 4, 5, 6, 14, 20, 3, 13, 13, 20, 15, 17, 9, 18, 1, 4, 18, 9, 11, 4, 10],
    Values = [56, 21, 59, 1, 93, 93, 34, 65, 98, 23, 65, 14, 81, 39, 82, 65, 78, 26, 20, 48, 98, 21, 70, 100, 68, 1, 77, 42, 63, 3, 15, 47, 40, 31, 8, 31, 73, 11, 11, 94, 63, 9, 98, 69, 99, 17, 17, 85, 61, 71],
    Optimal = 1927.

test_data(5, N, Cap, Weights, Values, Optimal) :-
    N = 50,
    Cap = 184,
    Weights = [9, 17, 20, 14, 7, 18, 7, 10, 13, 12, 15, 17, 15, 4, 8, 8, 3, 11, 1, 19, 18, 8, 19, 8, 1, 3, 2, 8, 3, 2, 11, 3, 17, 8, 9, 16, 7, 18, 5, 19, 19, 16, 8, 16, 14, 7, 4, 4, 14, 12],
    Values = [55, 53, 60, 94, 7, 87, 84, 83, 13, 8, 52, 94, 44, 14, 32, 25, 25, 69, 58, 18, 55, 24, 36, 60, 32, 10, 57, 71, 13, 7, 84, 70, 2, 12, 97, 31, 22, 53, 63, 62, 28, 52, 8, 22, 49, 1, 50, 34, 59, 37],
    Optimal = 1420.

main(Args) :-
    (Args = [test] ->
        test
    ; Args = [main] ->
        userinput
    ; write('Unknown argument.'), nl).

:- initialization(main, main).

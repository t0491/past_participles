% Use query "spanish(VARIABLE, [participle, past])." to receive the participle forms of the spanish words.
% Use query "spanish(Stem, [stem, infinitive])." to receive the set of words in the data set in their infinitive forms.
% Program will utilize properties.pl and phone.pl
% Program should only have six total outputs.
% Note that the program works on SWISH Prolog, on the browser, but not on SWI-Prolog application on the PC.
% The reason why is that SWI-Prolog cannot read special characters like 'β' or 'ð' so it throws an error on syntax.
% Other than that, if you were to write over those special characters with just 'b' or 'd' then it should work on SWI-Prolog.
% However, it will lose its meaning in a phonetic sense since 'β' and 'ð' are phones/pronunciations different from 'b' and 'd'.

% Function to remove last element from a list.
% I will need to to delete P1 and P2 from the stems when we want to suffix -ado or -ido onto the roots.
% If the element we delete is the only element in the list then the result is an empty list.
% Utilizes recursion.
% Used the code provided here:
% https://stackoverflow.com/questions/16174681/how-to-delete-the-last-element-from-a-list-in-prolog
% This is the only help online, that's not from the textbook or lecture videos, that I looked for and used.
% If there is any problem with this snippet of code I used, please let me know. I sourced it to show that
% it's not my own work.

:- [phone].

pop([X|Xs], Ys) :-
   prevpop(Xs, Ys, X).

prevpop([], [], _).
prevpop([X1|Xs], [X0|Ys], X0) :-
   prevpop(Xs, Ys, X1).

% Program focuses on the primary three verb types of spanish, which end in -ar, -er, and -ir.
% Uses /ɹ/ instead of /ɾ/ for amar and hablar.
% Reason is because the textbook and our class IPA chart does not have /ɾ/.
% Thus, all the underspecification will be for /ɹ/ as it will serve as r.

% Love - amar - amaɹ
spanish([a,m,P1,P2], [stem, infinitive]) :-
    phone(P1), low(P1), bck(P1),
    phone(P2), snt(P2), pal(P2), alv(P2), not(nas(P2)).

% Speak - hablar - aβlaɹ
spanish([a,b,l,P1,P2], [stem, infinitive]) :-
    phone(P1), low(P1), bck(P1),
    phone(P2), snt(P2), pal(P2), alv(P2), not(nas(P2)).

% Keep - tener - teneɹ
spanish([t,e,n,P1,P2], [stem, infinitive]) :-
    phone(P1), mid(P1), not(bck(P1)), not(ctr(P1)),
    phone(P2), snt(P2), pal(P2), alv(P2), not(nas(P2)).

% Drink - beber - beβeɹ
spanish([b,e,b,P1,P2], [stem, infinitive]) :-
    phone(P1), mid(P1), not(bck(P1)), not(ctr(P1)),
    phone(P2), snt(P2), pal(P2), alv(P2), not(nas(P2)).

% Live - vivir - biβiɹ
spanish([b,i,β,P1,P2], [stem, infinitive]) :-
    phone(P1), tns(P1), not(bck(P1)),
    phone(P2), snt(P2), pal(P2), alv(P2), not(nas(P2)).

% Divide - dividir - diβiðiɹ
spanish([d,i,β,i,ð,P1,P2], [stem, infinitive]) :-
    phone(P1), tns(P1), not(bck(P1)),
    phone(P2), snt(P2), pal(P2), alv(P2), not(nas(P2)).

% Participle suffix, will append -ado /aðo/ and -ido /iðo/ as needed.
% I would have put -ado and -ido together in one predicate,
% but I could not find a unique set of properties that ONLY those two share.
spanish([P1,ð,o], [suffix]) :- % For -ado
    phone(P1), str(P1), bck(P1), low(P1).

spanish([P1,ð,o], [suffix]) :- % For -ido
    phone(P1), str(P1), tns(P1), not(bck(P1)).

% Finds the stems, determine what kind of verb it is (-ar, -er, ir),
% obtain the roots, and then attach the appropriate participle suffixes onto them.

% For -ado specifically, so it will check for -ar.
spanish(Participle, [participle, past]) :-
    spanish(Stem, [stem, infinitive]),
    pop(Stem, RemainingStem), % Grabs the stem and removes the "r" from infinitive form.
    last(RemainingStem, Vowel), % Grabs the vowel before the "r" for checking.
    phone(Vowel), low(Vowel), bck(Vowel), % Checks "a" properties.
    spanish(Suffix, [suffix]),
	[HeadOfSuffix|_] = Suffix,
    phone(HeadOfSuffix), str(HeadOfSuffix), bck(HeadOfSuffix), low(HeadOfSuffix),
    pop(RemainingStem, Root),
    append(Root, Suffix, Participle).

% For -ido specifically, so it will check for -er or -ir.
% The condition I put to check "e" or "i" is as underspecified as possible.
% However, it will still include "ɪ" as there are no distinct properties to separate them from it while
% still "sharing" each other. It should not ever be a problem as long as the data set (if modified to
% include more words) follows the rules of including only infinitive verbs of -ar, -er, or -ir.
% -ɪr is not one of the verb types.

spanish(Participle, [participle, past]) :-
    spanish(Stem, [stem, infinitive]),
    pop(Stem, RemainingStem), % Grabs the stem and removes the "r" from infinitive form.
    last(RemainingStem, Vowel), % Grabs the vowel before the "r" for checking.
    phone(Vowel), str(Vowel), not(bck(Vowel)), not(ctr(Vowel)), not(low(Vowel)), % Checks "e" or "i" properties.
    spanish(Suffix, [suffix]),
	[HeadOfSuffix|_] = Suffix,
    phone(HeadOfSuffix), str(HeadOfSuffix), tns(HeadOfSuffix), not(bck(HeadOfSuffix)),
    pop(RemainingStem, Root),
    append(Root, Suffix, Participle).

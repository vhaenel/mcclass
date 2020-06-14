% Critical number of successes in binomial test
:- use_module(relevant).
:- use_module(intermediate).
:- use_module(library(mathml)).
:- use_module(library(http/html_write)).
:- consult(html).
:- consult(temp).
:- use_module(r).

mathml:math_hook(Flags, pi_0, Flags, sub(pi, 0)).
mathml:math_hook(Flags, pi_1, Flags, sub(pi, 1)).

%    
% Binomial density
%
:- multifile item/1.
item(uqbinom: binary_uqbinom(alpha, 'N', pi_0)).

:- multifile intermediate/1.
intermediate(uqbinom: binary_uqbinom/3).

:- multifile item//2.
item(uqbinom, Response) -->
    { Alpha <- alpha,
      NN <- 'N', [N] = NN,
      Pi_0 <- pi_0,
      Pi_1 <- pi_1,
      C = [k, dbinom(k, 'N', pi_0 = Pi_0), dbinom(k, 'N', pi_1 = Pi_1)], 
      maplist(mathml, C, Cols),
      findall(R, 
        ( between(0, N, K), 
	  P0 <- prob3(dbinom(K, 'N', pi_0)), 
	  P1 <- prob3(dbinom(K, 'N', pi_1)),
          maplist(mathml, [K, P0, P1], R)
        ), Rows)
    }, 
    html(
      [ div(class(card), div(class('card-body'),
          [ h1(class('card-title'), "Binary outcomes"),
            p(class('card-text'), 
              [ "Consider a clinical study with ", \mml('N' = round0(N)), " ",
                "patients. The variable ", \mml('X'), " represents the number ",
                "of therapeutic successes in the sample. We assume that the ",
		"successes occur independently, and under the null ",
		"hypothesis, the success probability is ", \mml(Pi_0), " in ",
		"all patients. The binomial probabilities are given in the ",
		"table below."
	      ]),
	    \table(Cols, Rows)
	  ])),
        div(class(card), div(class('card-body'),
          [ h4(class('card-title'), [a(id(question), []), "Question"]),
                \question(question, 
                response, 
                [ "How many successes are needed to rule out the null ",
                  "hypothesis at the one-tailed significance level ",
		  "of ", \nowrap([\mml(alpha = '100%'(Alpha)), "?"]) 
		], 
                Response)
	  ]))
      ]).

% Correctly identify as a paired t-test
:- multifile expert/5.
expert(uqbinom: binary_uqbinom, From >> To, _Flags, Feed, Hint) :-
    From = binary_uqbinom(Alpha, N, Pi),
    To   = binary_uqbinom_2(Alpha, N, Pi),
    Feed = "Correctly identified the problem as a binomial test.",
    Hint = "This is a binomial test.".

intermediate(uqbinom: binary_uqbinom_2/3).

expert(uqbinom: uqbinom, From >> To, _Flags, Feed, Hint) :-
    From = binary_uqbinom_2(Alpha, N, Pi),
    To   = natural(uqbinom(Alpha, N, Pi)),
    Feed = "Correctly identified the upper critical value.",
    Hint = "Report the upper critical value.".

:- multifile r_init/1.
r_init(uqbinom) :-
    r_init,
    {|r||
        uqbinom = function(...)
	{
	    1 + qbinom(..., lower.tail=FALSE)
	}

	prob3 = function(P)
	{
	    sprintf("%.3f", P)
	}

        alpha = 0.05
	N     = 26
	pi_0  = 0.6
	pi_1  = 0.75
    |}.

%
% Invoke example
%
:- multifile example/0.
example :-
    Topic = uqbinom,
    r_init(Topic),
    item(Topic: Item),
    solution(Topic, Item, Solution, Path),
    writeln(solution: Solution),
    r(Solution, Result),
    writeln(result: Result),
    writeln(path: Path),
    mathml(Solution = quantity(Result), Mathml),
    writeln(mathml: Mathml),
    hints(Topic, Item, Path, _, Hints),
    writeln(hints: Hints),
    traps(Topic, Item, Path, _, Traps),
    writeln(traps: Traps),
    praise(Topic, Item, Path, _, Praise),
    writeln(praise: Praise).

example :-
    Topic = uqbinom,
    r_init(Topic),
    item(Topic: Item),
    wrong(Topic, Item, Wrong, Woodden),
    writeln(wrong: Wrong),
    mathex(fix, Wrong, Fix),
    writeln(fix: Fix),
    mathex(show, Wrong, Show),
    writeln(show: Show),
    r(Wrong, Result),
    writeln(result: Result),
    writeln(path: Woodden),
    palette(Wrong, Flags),
    mathml([highlight(all) | Flags], Wrong \= Result, Mathml),
    writeln(mathml: Mathml),
    feedback(Topic, Item, Woodden, Flags, _, Feedback),
    writeln(feedback: Feedback),
    praise(Topic, Item, Woodden, Code_Praise, Praise),
    writeln(praise: Praise),
    mistakes(Topic, Item, Woodden, Flags, Code_Mistakes, Mistakes),
    writeln(mistakes: Mistakes),
    solution(Topic, Item, _, Path),
    hints(Topic, Item, Path, Code_Hints, _),
    relevant(Code_Praise, Code_Hints, Rel_Praise, Irrel_Praise),
    writeln(relevant_praise: Rel_Praise),
    writeln(irrelevant_praise: Irrel_Praise),
    traps(Topic, Item, Path, Code_Traps, _),
    relevant(Code_Mistakes, Code_Traps, Rel_Mistakes, Irrel_Mistakes),
    writeln(relevant_mistakes: Rel_Mistakes),
    writeln(irrelevant_mistakes: Irrel_Mistakes).

example :-
    Topic = uqbinom,
    html(\item(Topic, ''), HTML, []),
    print_html(HTML).

example :-
    Topic = uqbinom,
    buggies(Topic, Bugs),
    writeln(bugs: Bugs).


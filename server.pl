% swipl server.pl --port=8001 --pidfile=http.pid

:- use_module(library(http/thread_httpd)).
:- use_module(library(http/http_dispatch)).
:- use_module(library(http/http_error)).
:- use_module(library(http/http_log)).
:- use_module(library(http/html_write)).
:- use_module(library(http/http_files)).
:- use_module(library(http/http_unix_daemon)).
:- use_module(library(http/http_parameters)).
:- use_module(library(http/http_session)).

:- use_module(search).
:- use_module(tpaired).

:- initialization http_daemon.

:- multifile http:location/3.
:- dynamic http:location/3.

http:location(mcclass, root(mcclass), []).

:- http_handler(mcclass('favicon.ico'), http_reply_file('favicon.ico', []), []).
:- http_handler(mcclass(tpaired), handler(tpaired), []).
:- http_handler(mcclass(confint), handler(confint), []).
:- http_handler(mcclass(.), http_redirect(see_other, mcclass(tpaired)), []).
:- http_handler(root(.), http_redirect(see_other, mcclass(.)), []).

handler(Task, Request) :-
    member(method(post), Request),
    !,
    http_parameters(Request, [], [form_data(Data)]),
    handle(Task, Data).

handler(Task, _) :-
    handle(Task, []).

% Task sheet
handle(Task, Data) :-
    start(Task, Item),
    % Das kommt noch weg, das muss man nicht bei jedem Seitenaufbau laufen lassen.
    findall(Expression-Flags, search(Task, Expression, Flags), Solutions),
    term_string(Solutions, String),
    reply_html_page(
      [ title('McClass'),
        link(
	  [ rel(stylesheet),
	    href('https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css'),
	    integrity('sha384-JcKb8q3iqJ61gNV9KGb8thSsNjpSL0n8PARn9HuZOnIxN0hoP+VmmDGMN5t9UJ0Z'),
	    crossorigin(anonymous)]),
	link(
	  [ rel(icon), 
            href('/mcclass/favicon.ico'),
	    type('image/x-icon')]),
        meta(
	  [ name(viewport), 
            content('width=device-width, initial-scale=1')])
      ],
    [ \render(Task, Item, Data),
      p(String)
    ]).

handle(Task, _) :-
    reply_html_page(
      [ title('McClass'),
        link(
      [ rel(stylesheet),
        href('https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css'),
        integrity('sha384-JcKb8q3iqJ61gNV9KGb8thSsNjpSL0n8PARn9HuZOnIxN0hoP+VmmDGMN5t9UJ0Z'),
        crossorigin(anonymous)]),
    link(
      [ rel(icon),
            href('/mcclass/favicon.ico'),
        type('image/x-icon')]),
        meta(
      [ name(viewport),
            content('width=device-width, initial-scale=1')])
      ],
      p("not found: ~w"-Task)
    ).

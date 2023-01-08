-module(erlav_nif).

-export([add/2, encode/2, etest/0, etest/1, create_encoder/1, do_encode/2, perf_tst/0]).

-nifs([add/2, encode/2, create_encoder/1, do_encode/2]).

-on_load(init/0).

-define(APPNAME, erlav_nif).
-define(LIBNAME, erlav_nif).

init() ->
    SoName =
        case code:priv_dir(?APPNAME) of
            {error, bad_name} ->
                case filelib:is_dir(filename:join(["..", priv])) of
                    true ->
                        filename:join(["..", priv, ?LIBNAME]);
                    _ ->
                        filename:join([priv, ?LIBNAME])
                end;
            Dir ->
                filename:join(Dir, ?LIBNAME)
        end,
    erlang:load_nif(SoName, 0).

add(_A, _B) ->
    not_loaded(?LINE).

encode(_A, _B) ->
    not_loaded(?LINE).
    
do_encode(_A, _B) ->
    not_loaded(?LINE).

not_loaded(Line) ->
    erlang:nif_error({not_loaded, [{module, ?MODULE}, {line, Line}]}).

create_encoder(_A) ->
    not_loaded(?LINE).

etest() ->
    {ok, SchemaJSON} = file:read_file("priv/tschema2.avsc"),
    Encoder = avro:make_simple_encoder(SchemaJSON, []),
    Term = #{
        <<"intField">> => 789,
        <<"longField">> => 2989898111,
        <<"doubleField">> => 11.2345,
        <<"floatField">> => 23.12,
        <<"boolField">> => true,
        <<"stringField">> => <<"asdadasdasdasd3453534dfgdgd123456789">>
    },
    iolist_to_binary(Encoder(Term)).

etest(3) ->
    {ok, SchemaJSON} = file:read_file("priv/tschema3.avsc"),
    Encoder = avro:make_simple_encoder(SchemaJSON, []),
    Term = #{
        <<"intField">> => 1,
        <<"longField">> => 2
    },
    R1 = iolist_to_binary(Encoder(Term)),
    io:format("R1: ~p ~n", [R1]),
    Ret = encode(8, Term),
    io:format("c++ ret: ~p ~n", [Ret]),
    ok;


etest(4) ->
    {ok, SchemaJSON} = file:read_file("priv/tschema4.avsc"),
    Encoder = avro:make_simple_encoder(SchemaJSON, []),
    Term = #{
        <<"intField">> => 1,
        <<"longField">> => 2
    },
    iolist_to_binary(Encoder(Term));

etest(2) ->
    Term = #{
        <<"intField">> => 789,
        <<"longField">> => 2989898111,
        <<"doubleField">> => 11.2345,
        <<"floatField">> => 23.12,
        <<"boolField">> => true,
        <<"stringField">> => <<"asdadasdasdasd3453534dfgdgd123456789">>
    },
    Ret = encode(7, Term),
    io:format("c++ ret: ~p ~n", [Ret]),
    {ok, SchemaJSON} = file:read_file("priv/tschema2.avsc"),
    Decoder = avro:make_simple_decoder(SchemaJSON, []),
    Decoder(Ret);

etest(1) ->
    EA1 = [iolist_to_binary(avro_binary_encoder:encode_value({avro_value,{avro_primitive_type,<<"int">>,[]},X})) 
           ||  X <- lists:seq(1,10)],
    io:format("Erlavro INT ~p ~n", [EA1]),
    EA2 = [ encode(1, X) || X <- lists:seq(1,10)],
    io:format("Erlav INT ~p ~n", [EA2]),
    EA3 = [iolist_to_binary(avro_binary_encoder:encode_value({avro_value,{avro_primitive_type,<<"long">>,[]},X})) 
           ||  X <- lists:seq(9223372036854775707, 9223372036854775717)],
    io:format("Erlavro LONG ~p ~n", [EA3]),
    EA4 = [ encode(2, X) || X <- lists:seq(9223372036854775707, 9223372036854775717)],
    io:format("Erlav LONG ~p ~n", [EA4]),


    EA5 = [iolist_to_binary(avro_binary_encoder:encode_value({avro_value,{avro_primitive_type,<<"float">>,[]},X})) 
           ||  X <- [1.0, 1.234, 3.456, 567.89] ],
    io:format("Erlavro Float ~p ~n", [EA5]),
    EA6 = [encode(3, X) ||  X <- [1.0, 1.234, 3.456, 567.89] ],
    io:format("Erlav Float ~p ~n", [EA6]),
    
    EA7 = [iolist_to_binary(avro_binary_encoder:encode_value({avro_value,{avro_primitive_type,<<"double">>,[]},X})) 
           ||  X <- [1.0, 1.234, 3.456, 567.89] ],
    io:format("Erlavro double ~p ~n", [EA7]),
    EA8 = [encode(4, X) ||  X <- [1.0, 1.234, 3.456, 567.89] ],
    io:format("Erlav double ~p ~n", [EA8]),
    
    EA9 = [iolist_to_binary(avro_binary_encoder:encode_value({avro_value,{avro_primitive_type,<<"boolean">>,[]},X}))
          || X <- [true, false] ],
    io:format("Erlavro boolean ~p ~n", [EA9]),
    EA10 = [encode(5, X) ||  X <- [true, false] ],
    io:format("Erlav boolean ~p ~n", [EA10]),

    S1 = iolist_to_binary(avro_binary_encoder:encode_value({avro_value,{avro_primitive_type,<<"string">>,[]}, <<"qwertyasdfgzxcv">>})),
    io:format("Erlavro string ~p ~n", [S1]),
    S2 = encode(6, <<"qwertyasdfgzxcv">>),
    io:format("Erlav string ~p ~n", [S2]),

    ok.

perf_tst() ->
    {ok, SchemaJSON} = file:read_file("priv/perf_schema.avsc"),
    Encoder = avro:make_simple_encoder(SchemaJSON, []),
    Term = #{
        <<"intField">> => 789,
        <<"longField">> => 2989898111,
        <<"doubleField">> => 11.2345,
        <<"floatField">> => 23.12,
        <<"boolField">> => true,
        <<"stringField">> => <<"asdadasdasdasd3453534dfgdgd123456789">>,
        <<"stringField1">> => <<"1f9a8371-659e-4efb-95c3-d6bda20fd000">>,
        <<"stringField2">> => <<"02c52125-d49d-4df2-a6c1-fa49a0286694">>,
        <<"stringField3">> => <<"62f267fb-276c-4452-8967-406d732cb621">>,
        <<"stringField4">> => <<"316693e0-253c-485e-b42a-f091a49993de">>,
        <<"stringField5">> => <<"483f4ebc-dcba-46f2-bc85-4f42ecb357bf">>,
        <<"stringField6">> => <<"0d177b44-c867-4b2e-a4b9-5866aff23720">>,
        <<"stringField7">> => <<"1869ab3c-8949-477f-804f-221722e39304">>,
        <<"stringField8">> => <<"05c38ce8-3573-46d8-9d1c-3ca4a8abc451">>,
        <<"stringField9">> => <<"31d55319-16f7-4bfe-b1b0-973b258eb758">>,
        <<"stringField10">> => <<"31d55319-16f7-4bfe-b1b0-973b258eb758">>,
        <<"stringField11">> => <<"31d55319-16f7-4bfe-b1b0-973b258eb758">>,
        <<"stringField12">> => <<"31d55319-16f7-4bfe-b1b0-973b258eb758">>,
        <<"stringField13">> => <<"31d55319-16f7-4bfe-b1b0-973b258eb758">>,
        <<"stringField14">> => <<"31d55319-16f7-4bfe-b1b0-973b258eb758">>,
        <<"stringField15">> => <<"31d55319-16f7-4bfe-b1b0-973b258eb758">>,
        <<"stringField16">> => <<"31d55319-16f7-4bfe-b1b0-973b258eb758">>,
        <<"stringField17">> => <<"31d55319-16f7-4bfe-b1b0-973b258eb758">>,
        <<"stringField18">> => <<"31d55319-16f7-4bfe-b1b0-973b258eb758">>,
        <<"stringField19">> => <<"31d55319-16f7-4bfe-b1b0-973b258eb758">>,
        <<"stringField20">> => <<"31d55319-16f7-4bfe-b1b0-973b258eb758">>
    },
    R1 = iolist_to_binary(Encoder(Term)),
    SchemaId = erlav_nif:create_encoder(<<"priv/perf_schema.avsc">>),
    Ret = erlav_nif:do_encode(SchemaId, Term),
    %R1 = Ret,
    RSize = size(Ret),
    RSize1 = size(R1),
    io:format("ret size: E:~p C:~p ~n", [RSize1, RSize]),
    %io:format("ERet: ~p ~n", [R1]),
    %io:format("CRet: ~p ~n", [Ret]),

    L = lists:seq(1, 1000000),
    EStart = erlang:system_time(millisecond),
    lists:foreach(fun(_)-> iolist_to_binary(Encoder(Term)) end, L),
    ETime = erlang:system_time(millisecond) - EStart,

    CStart = erlang:system_time(millisecond),
    lists:foreach(fun(_)-> erlav_nif:do_encode(SchemaId, Term) end, L),
    CTime = erlang:system_time(millisecond) - CStart,

    io:format(" - ETime: ~p , CTime: ~p ~n", [ETime, CTime]),
    ok.
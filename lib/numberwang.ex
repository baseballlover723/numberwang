# TODO change the output to be more numberwang
# TODO change to loop until its numberwang
# TODO don't define number of rounds, end at WangerNumb
defmodule Numberwang do
  def start_game(players, rounds) do
    state = %{
      :players =>
        players
        |> Enum.map(fn player ->
          {player, %{:name => player, :guesses => generate_guesses(rounds), :score => 0}}
        end),
      :round_counter => 1
    }

    # IO.inspect(state, label: "starting state", charlists: :as_lists)

    play_round(state, rounds)

    # play_round(state, 0)
  end

  def play_round(state, 0) do
    # IO.inspect(state, label: "calc end state", charlists: :as_lists)

    players = Map.get(state, :players)
    numb_players = length(players)

    ending_str =
      players
      |> Enum.map(fn {_name, player} -> player end)
      |> Enum.sort_by(fn player -> Map.get(player, :score) * -1 end)
      # |> IO.inspect(label: "sorted players", charlists: :as_lists)
      |> Stream.with_index(1)
      |> Enum.map(fn {player, rank} ->
        output_player_with_rank(player, rank, numb_players)
      end)
      |> Enum.join("\n")

    # IO.puts("\nGame is Over!\n")
    IO.puts("Thats WangerNumb!\n")
    IO.puts(ending_str)
    IO.puts("Until next time, stay Numberwang!")
  end

  def play_round(%{round_counter: round_number, players: players} = state, rounds_left) do
    # IO.puts("\nPlaying round #{round_number} / #{round_number + rounds_left - 1}")
    IO.puts("\n" <> round_name(round_number))
    # IO.inspect(state, label: "play round #{round_number} state", charlists: :as_lists)
    players =
      Enum.map(players, fn {name, player} ->
        {name, play_turn(player)}
      end)

    state = Map.put(state, :players, players)

    state = Map.update!(state, :round_counter, fn count -> count + 1 end)
    play_round(state, rounds_left - 1)
  end

  def output_player_with_rank(%{name: name, score: score}, rank, numb_players) do
    output_rank(rank, numb_players) <> "#{name} with #{score}"
  end

  def output_rank(rank, numb_players) do
    case rank do
      1 -> "Numberwang!: "
      ^numb_players -> "Wangernumb!: "
      rank -> String.pad_leading(Number.Human.number_to_ordinal(rank) <> ": ", 13)
    end
  end

  def round_name(1) do
    "Lets play Numberwang!"
  end

  # TODO add more
  def round_name(round) do
    Enum.random([
      "Now onto round #{round}!",
      "Let's go to the next board!",
      "Let's rotate the board!"
    ]) <> " (#{round})"
  end

  def play_turn(%{name: name, guesses: [guess_value | guesses], score: score} = player) do
    # IO.inspect(player, label: "play turn #{name} state", charlists: :as_lists)
    IO.puts(name <> "?")
    IO.puts("#{guess_value}?")

    guess_result = guess(guess_value)

    score_change =
      case guess_result do
        :"That's Numberwang!" ->
          points = generate_score()
          IO.puts("That's Numberwang! #{points} points for #{name}")
          points

        _ ->
          0
      end

    # IO.inspect(score_change, label: "score change")
    player
    |> Map.put(:guesses, guesses)
    |> Map.put(:score, score + score_change)
  end

  def guess(_numb) do
    if :rand.uniform() < 0.2 do
      :"That's Numberwang!"
    else
      :Incorrect
    end
  end

  def generate_score() do
    :rand.uniform(10)
  end

  def generate_guesses(number_of_guesses \\ 12, guesses \\ [])

  def generate_guesses(number_of_guesses, guesses) when number_of_guesses <= 0 do
    guesses
  end

  def generate_guesses(number_of_guesses, guesses) do
    generate_guesses(number_of_guesses - 1, [generate_guess() | guesses])
  end

  # TODO sometimes generate negative nubmers?
  def generate_guess() do
    probabilities =
      create_probability_table(%{:int => 0.5, :float => 0.3, :sqrt => 0.1, :expression => 0.1})

    type = rand_case(probabilities)
    # IO.inspect(type, label: "guess_type", charlists: :as_lists)

    case type do
      :int -> rand_int()
      :float -> rand_float()
      :sqrt -> rand_sqrt()
      :expression -> rand_expression()
      _ -> raise "unmatched"
    end
  end

  # TODO make it probabilistic based on the length of the string value, but keep it an int?
  def rand_int() do
    :rand.uniform(1_000)
  end

  # TODO make it probabilistic based on the length of the string value, but keep it a float?
  def rand_float() do
    (rand_int() + :rand.uniform())
    |> Float.round(:rand.uniform(3))
  end

  def rand_sqrt() do
    probabilities = create_probability_table(%{:int => 0.9, :float => 0.1})
    type = rand_case(probabilities)

    "√(" <>
      case type do
        :int -> rand_int() |> Integer.to_string()
        :float -> rand_float() |> Float.to_string()
        _ -> raise "unmatched"
      end <> ")"
  end

  def rand_expression() do
    value_probabilities = create_probability_table(%{:int => 0.9, :float => 0.1})

    operator_probabilities =
      create_probability_table(%{:add => 0.5, :sub => 0.25, :multi => 0.1875, :div => 0.0625})

    operator_type = rand_case(operator_probabilities)
    value_type1 = rand_case(value_probabilities)
    value_type2 = rand_case(value_probabilities)

    case value_type1 do
      :int -> rand_int() |> Integer.to_string()
      :float -> rand_float() |> Float.to_string()
      _ -> raise "unmatched"
    end <>
      " " <>
      case operator_type do
        :add -> "+"
        :sub -> "-"
        :multi -> "*"
        :div -> "/"
        _ -> raise "unmatched"
      end <>
      " " <>
      case value_type2 do
        :int -> rand_int() |> Integer.to_string()
        :float -> rand_float() |> Float.to_string()
        _ -> raise "unmatched"
      end
  end

  def create_probability_table(probabilities) do
    total_probability =
      Map.values(probabilities)
      |> Enum.sum()

    if total_probability > 1.0 + 0.000_1 or total_probability < 1.0 - 0.000_1,
      do: raise("invalid probabilities")

    probabilities
  end

  def rand_case(probabilities) do
    numb = :rand.uniform()

    Map.to_list(probabilities)
    |> List.foldl(numb, fn {key, value}, acc ->
      cond do
        is_atom(acc) -> acc
        acc < value -> key
        true -> acc - value
      end
    end)
  end
end

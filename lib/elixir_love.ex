defmodule ElixirLove do
  @moduledoc """
  ElixirLove keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  def hello(), do: :world

  def intro() do
    [
      name: "James",
      background: [
        "started using elixir since 2016.",
        "mainly use it for web development in works."
      ],
      current_work: [
        {:crypto_dot_com,
         [
           "use elixir to build operation panel and microservices."
         ]}
      ]
    ]
  end

  def why_elixir() do
    [
      phoenix: [
        "Phoenix rocks!!!",
        "Phoenix Live View rocks!!!"
      ],
      functional: [
        "a way of thinking about software with pure functions",
        "immutable",
        "expressive and declarative"
      ],
      processes: [
        "basis for concurrency for Elixir & Erlang"
      ],
      best_of_both_worlds: [
        oo: [
          "isolated objects (Erlang processes)",
          "communicate with messages only"
        ],
        functional: [
          "expressive and declarative codebase"
        ]
      ]
    ]
  end

  def test_run_genetic_one_max() do
    genotype = fn -> for _ <- 1..1000, do: Enum.random(0..3) end
    fitness_function = fn chromosome -> Enum.sum(chromosome) end
    max_fitness = 1000
    soln = ElixirLove.Genetic.run(fitness_function, genotype, max_fitness)
    IO.write("\n")
    IO.inspect(soln)
  end
end

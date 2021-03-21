defmodule ElixirLove.Genetic do
  # Initial Population
  # Evaluate Population
  # Select Parents
  # Create Children
  # Repeat the Process with new Population

  def run(fitness_function, genotype, max_fitness, opts \\ []) do
    genotype
    |> initialize()
    |> evolve(fitness_function, genotype, max_fitness, opts)
  end

  defp evolve(population, fitness_function, genotype, max_fitness, opts \\ []) do
    population = population |> evaluate(fitness_function, opts)
    best = hd(population)
    current_best = fitness_function.(best)
    IO.inspect("\rCurrent Best: #{current_best}")

    if current_best == max_fitness do
      best
    else
      population
      |> select(opts)
      |> crossover(opts)
      |> mutation(opts)
      |> evolve(fitness_function, genotype, max_fitness, opts)
    end
  end

  def initialize(genotype, opts \\ []) do
    popluation_size = Keyword.get(opts, :population_size, 100)
    for _ <- 1..popluation_size, do: genotype.()
  end

  defp evaluate(population, fitness_function, opts \\ []) do
    Enum.sort_by(population, fitness_function, &>=/2)
  end

  defp select(population, opts \\ []) do
    population
    |> Enum.chunk_every(2)
    |> Enum.map(&List.to_tuple(&1))
  end

  defp crossover(population, opts \\ []) do
    population
    |> Enum.reduce([], fn {p1, p2}, acc ->
      cx_point = :rand.uniform(length(p1))

      {
        {h1, t1},
        {h2, t2}
      } = {
        Enum.split(p1, cx_point),
        Enum.split(p2, cx_point)
      }

      [h1 ++ t2, h2 ++ t1 | acc]
    end)
  end

  def mutation(population, opts \\ []) do
    population
    |> Enum.map(fn chromosome ->
      if :rand.uniform() < 0.05 do
        Enum.shuffle(chromosome)
      else
        chromosome
      end
    end)
  end
end

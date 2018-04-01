defmodule Identicon do
  def main(input) do
    input
    |> hash_input
    |> pick_color
    |> build_grid
    |> filter_odd_squares
    |> build_pixel_map
    |> draw_image
    |> save_image(input)
  end

  def hash_input(input) do
    hex = :crypto.hash(:md5, input)
    |> :binary.bin_to_list

    %Identicon.Image{hex: hex}
  end

  def pick_color(image) do
    %Identicon.Image{ hex: [r, g, b | _tail]} = image

    %Identicon.Image{ image | color: {r, g, b}}
  end

  def pick_color2(%Identicon.Image{ hex: [r, g, b | _tail]} = image) do
    %Identicon.Image{ image | color: {r, g, b}}
  end

  def build_grid(%Identicon.Image{hex: hex_code} = image) do
    grid = hex_code
    |> Enum.chunk(3)
    #|> Enum.map(fn(x) -> mirror_rows(x) end)
    |> Enum.map(&mirror_rows/1)
    |> List.flatten
    |> Enum.with_index

    %Identicon.Image{image | grid: grid }
  end

  def mirror_rows([a, b, c]) do
    [a, b, c, b, a]
  end

  def filter_odd_squares(%Identicon.Image{grid: grid} = image) do
    grid = Enum.filter grid, fn({x, _y}) ->
      rem(x, 2) == 0
    end
    %Identicon.Image{image | grid: grid }
  end

  def build_pixel_map(%Identicon.Image{grid: grid} = image) do
    pixel_map = Enum.map grid, fn({_code , index}) ->
      horizontal = rem(index,5)*50
      vertical = div(index,5)*50
      {{horizontal,vertical},{horizontal+50,vertical+50}}
    end

    %Identicon.Image{image | pixel_map: pixel_map }
  end

  def draw_image(%Identicon.Image{color: color, pixel_map: pixel_map}) do
    image = :egd.create(250,250)
    fill = :egd.color(color)

    Enum.each pixel_map, fn({start,stop}) ->
      :egd.filledRectangle(image,start,stop,fill)
    end

    :egd.render(image)
  end

  def save_image(image,input) do
    File.write("#{input}.png", image)
  end
end

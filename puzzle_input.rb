module PuzzleInput
  def load_from_text_file(file_path, separator="\n")
    File.read(file_path).split("\n")
  end
  module_function :load_from_text_file
end
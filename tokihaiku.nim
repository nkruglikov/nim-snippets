import random
import times
import strutils
from math import cumsummed


proc generateSyllable(isFirst = false): string =
  var syllableStructure: string
  if isFirst:
    syllableStructure = random.sample(
      ["cvn", "cv", "vn", "v"],
      [10, 75, 5, 10].cumsummed
    )
  else:
    syllableStructure = random.sample(
      ["cvn", "cv"],
      [10, 75].cumsummed
    )

  let vowels = "aeiou"
  let consonants = "ptksmnljw"

  for syllable in syllableStructure:
    case syllable
    of 'c': result &= $sample(consonants)
    of 'v': result &= $sample(vowels)
    of 'n': result &= "n"
    else: discard


proc generateWord(nSyllables: int): string =
  result = generateSyllable(isFirst=true)
  for i in 1 ..< nSyllables:
    result &= generateSyllable()


proc generateSyllableLength(): int =
  return sample(
    [1, 2, 3],
    [2, 7, 1].cumsummed
  )


proc generateWords(nSyllables: int): seq[string] =
  var remainingSyllables = nSyllables
  while remainingSyllables > 0:
    var wordSyllables: int
    while true:
      wordSyllables = generateSyllableLength()
      if wordSyllables <= remainingSyllables:
        break
    result.add(generateWord(wordSyllables))
    remainingSyllables -= wordSyllables


proc generateHaiku(): string =
  result = [
    generateWords(5).join(" "),
    generateWords(7).join(" "),
    generateWords(5).join(" ")
  ].join("\n")


random.randomize()
echo generateHaiku()

let now = getTime()
for i in 1 .. 10000:
  discard generateHaiku()
echo getTime() - now

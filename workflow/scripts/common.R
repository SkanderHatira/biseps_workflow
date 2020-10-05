aggregate = function(el){
	GRanges = readBismark(el)
}


joinBio = function(list){
  for (el in list){
	join = joinReplicates(join,el)
  }
  return(join)
}

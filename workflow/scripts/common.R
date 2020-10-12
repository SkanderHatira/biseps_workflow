aggregate = function(el){
	GRanges = readBismark(el)
}

joinBio = function(list,join){
  for (el in list){
	join = joinReplicates(join,el)
  }
  return(join)
}


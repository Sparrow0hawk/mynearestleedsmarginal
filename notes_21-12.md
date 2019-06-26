With altered datasets can now render map.

However order of wards is incorrect, this appears to relate to order of the
shapefile but reordering the results dataframe to match apparent order of
shapefile does not solve the problem.

# command to reorder results dataframe
incumbents_df <- incumbents_df[shape_leeds$WARDID,]

# may also be an issue within nearest marginal match but we'll come to that
once initial mapping is correct.


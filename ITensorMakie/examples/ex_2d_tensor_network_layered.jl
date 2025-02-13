using ITensors
using ITensorMakie
using Graphs
using GLMakie
using LayeredLayouts

tn = itensornetwork(grid((4, 4)); linkspaces=3)
layout(g) = layered_layout(solve_positions(Zarate(), g))
@visualize fig tn arrow_show = true layout = layout

fig

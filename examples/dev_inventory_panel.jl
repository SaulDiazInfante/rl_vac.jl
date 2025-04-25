args = build_testing_parameters()
process_first_inventory_reorder_point!(args)
initial_condition = copy(args["initial_condition"])
state = copy(args["state"])
model_parameters = copy(args["model_parameters"])
numeric_solver_parameters = copy(args["numeric_solver_parameters"])
inventory_parameters = copy(args["inventory_parameters"])

list_solution = Matrix{Real}[]
df_solution = DataFrame()

vaccine_coverage = get_vaccine_stock_coverage(args)
vaccination_rate = get_max_vaccination_rate!(vaccine_coverage, args)
args["state"].action = vaccination_rate
args["initial_condition"].action = vaccination_rate
stage_solution = optimize_stage_solution!(args)
push!(list_solution, stage_solution)

# Plotting
fig = Figure(resolution=(800, 600))

t = stage_solution[:, 1]
y1 = POP_SIZE * stage_solution[:, 13]
y2 = POP_SIZE * stage_solution[:, 15]
y3 = stage_solution[:, 14]
y3_active_loss = max.(-70.0, y3)
points = Point2f.(t, y3_active_loss)
ax1 = Axis(
    fig[1, 1],
    title="Inventory Size (vaccine jabs)",
    ylabel=L"K^{t_{n}^{k}} "
)
ax2 = Axis(
    fig[2, 1],
    title="Inventory Loss (vaccine jabs)",
    ylabel=L" L^{t_{n}^{(k)}}"
)
ax3 = Axis(
    fig[3, 1],
    title="Temperature (celsius)",
    ylabel=L"T(t)",
    xlabel=L"t (\text{days})"
)

linkxaxes!(ax1, ax2, ax3)
lines!(ax1, t, y1)
lines!(ax2, t, y2)
lines!(ax3, t, y3)
lines!(ax3, t, y3_active_loss)

poly!(
    ax3,
    points,  # y coordinates
    color=(:blue, 0.2),                 # transparent blue
    strokewidth=0
)

hlines!(ax3, -70.0, color=:red, linestyle=:dash)

save("InventoryPanel01.pdf", fig)
fig
time_reorder_points = inventory_parameters.t_delivery

for (k, t_k) in enumerate(time_reorder_points[2:end-1])
    println("reorder time-point: ($k, $t_k)")
    process_inventory_reorder_point!(args)
    vaccine_coverage = get_vaccine_stock_coverage(args)
    vaccination_rate = get_max_vaccination_rate!(vaccine_coverage, args)
    args["state"].action = vaccination_rate
    args["initial_condition"].action = vaccination_rate
    stage_solution = optimize_stage_solution!(args)
    push!(list_solution, stage_solution)
    t = stage_solution[:, 1]
    y1 = POP_SIZE * stage_solution[:, 13]
    y2 = POP_SIZE * stage_solution[:, 15]
    y3 = stage_solution[:, 14]

    y3_active_loss = max.(-70.0, y3)
    points = Point2f.(t, y3_active_loss)

    lines!(ax1, t, y1)
    lines!(ax2, t, y2)
    lines!(ax3, t, y3)
    hlines!(ax3, -70.0, color=:red, linestyle=:dash)
    poly!(
        ax3,
        points,  # y coordinates
        color=(:blue, 0.2),                 # transparent blue
        strokewidth=0
    )
end
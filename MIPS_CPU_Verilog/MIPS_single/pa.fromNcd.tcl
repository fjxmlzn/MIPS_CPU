
# PlanAhead Launch Script for Post PAR Floorplanning, created by Project Navigator

create_project -name MIPS_Single -dir "E:/work/ise/MIPS_single/planAhead_run_5" -part xc6slx16csg324-3
set srcset [get_property srcset [current_run -impl]]
set_property design_mode GateLvl $srcset
set_property edif_top_file "E:/work/ise/MIPS_single/CPU.ngc" [ get_property srcset [ current_run ] ]
add_files -norecurse { {E:/work/ise/MIPS_single} }
set_property target_constrs_file "E:/work/ise/MIPS_single/src/top.ucf" [current_fileset -constrset]
add_files [list {E:/work/ise/MIPS_single/src/top.ucf}] -fileset [get_property constrset [current_run]]
link_design
read_xdl -file "E:/work/ise/MIPS_single/CPU.ncd"
if {[catch {read_twx -name results_1 -file "E:/work/ise/MIPS_single/CPU.twx"} eInfo]} {
   puts "WARNING: there was a problem importing \"E:/work/ise/MIPS_single/CPU.twx\": $eInfo"
}

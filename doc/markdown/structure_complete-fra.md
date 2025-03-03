<pre>

[ <a href="../../bin/text_io.ads">text_io</a> ..........\
[<a href="../../bin/text_io.adb">bdy</a>                |
                    |
[ <a href="../../bin/sequential_io.ads">sequential_io</a> ..\ |
[bdy              | |
                  | |
                  | |    <span style="background-color:yellow">[ <a href="../../src/par_phase/lex.ads">lex</a> </span>.......\
                  | \..> <span style="background-color:#E0E0E0">[<a href="../../src/par_phase/lex.adb">bdy</a>  </span>       |
                  |                   |
                  |      <span style="background-color:yellow">[ <a href="../../src/par_phase/grmr_ops.ads">grmr_ops</a> </span>..|
                  |      <span style="background-color:#E0E0E0">[<a href="../../src/par_phase/grmr_ops.adb">bdy</a>       </span>  |
                  |                   |
                  \....> <span style="background-color:yellow">[ <a href="../../src/par_phase/grmr_tbl.ads">grmr_tbl</a> </span>..|
                                      |    <span style="background-color:yellow">[ <a href="../../src/ada_comp/idl.ads">idl</a>              </span>
                                      |    <span style="background-color:yellow">|</span> <span style="background-color:yellow">( par_phase      </span>
                                      |    <span style="background-color:yellow">|</span> <span style="background-color:yellow">( lib_phase      </span>
                                      |    <span style="background-color:yellow">|</span> <span style="background-color:yellow">( sem_phase      </span>
                                      |    <span style="background-color:yellow">|</span> <span style="background-color:yellow">( err_phase      </span>
                                      |    <span style="background-color:yellow">|</span> <span style="background-color:yellow">( write_lib      </span>
                                      |    <span style="background-color:#E0E0E0">[<a href="../../src/ada_comp/idl.adb">bdy</a>               </span>
                                      \..> <span style="background-color:#E0E0E0">|</span> <span style="background-color:#E0E0E0">_( <a href="../../src/par_phase/idl-par_phase.adb">par_phase</a>     </span>
                                           <span style="background-color:#E0E0E0">|</span>    <span style="background-color:#E0E0E0">|</span> <span style="background-color:#E0E0E0">_( <a href="../../src/par_phase/idl-par_phase-set_dflt.adb">set_dflt</a> </span>
                                           <span style="background-color:#E0E0E0">|</span> <span style="background-color:#E0E0E0">_( <a href="../../src/ada_comp/idl-lib_phase.adb">lib_phase</a>     </span>
                                           <span style="background-color:#E0E0E0">|</span> <span style="background-color:#E0E0E0">_( <a href="../../src/sem_phase/idl-sem_phase.adb">sem_phase</a>     </span>
                                           <span style="background-color:#E0E0E0">|</span>    <span style="background-color:#E0E0E0">|</span> <span style="background-color:#E0E0E0">_[ <a href="../../src/sem_phase/idl-sem_phase-aggreso.adb">aggreso</a>  </span>
                                           <span style="background-color:#E0E0E0">|</span>    <span style="background-color:#E0E0E0">|</span> <span style="background-color:#E0E0E0">_[ <a href="../../src/sem_phase/idl-sem_phase-att_walk.adb">att_walk</a> </span>
                                           <span style="background-color:#E0E0E0">|</span>    <span style="background-color:#E0E0E0">|</span> <span style="background-color:#E0E0E0">_[ <a href="../../src/sem_phase/idl-sem_phase-chk_stat.adb">chk_stat</a> </span>
                                           <span style="background-color:#E0E0E0">|</span>    <span style="background-color:#E0E0E0">|</span> <span style="background-color:#E0E0E0">_[ <a href="../../src/sem_phase/idl-sem_phase-def_util.adb">def_util</a> </span>
                                           <span style="background-color:#E0E0E0">|</span>    <span style="background-color:#E0E0E0">|</span> <span style="background-color:#E0E0E0">_[ <a href="../../src/sem_phase/idl-sem_phase-def_walk.adb">def_walk</a> </span>
                                           <span style="background-color:#E0E0E0">|</span>    <span style="background-color:#E0E0E0">|</span> <span style="background-color:#E0E0E0">_[ <a href="../../src/sem_phase/idl-sem_phase-derived.adb">derived</a>  </span>
                                           <span style="background-color:#E0E0E0">|</span>    <span style="background-color:#E0E0E0">|</span> <span style="background-color:#E0E0E0">_[ <a href="../../src/sem_phase/idl-sem_phase-eval_num.adb">eval_num</a> </span>
                                           <span style="background-color:#E0E0E0">|</span>    <span style="background-color:#E0E0E0">|</span> <span style="background-color:#E0E0E0">_[ <a href="../../src/sem_phase/idl-sem_phase-expreso.adb">expreso</a>  </span>
                                           <span style="background-color:#E0E0E0">|</span>    <span style="background-color:#E0E0E0">|</span> <span style="background-color:#E0E0E0">_[ <a href="../../src/sem_phase/idl-sem_phase-exp_type.adb">exp_type</a> </span>
                                           <span style="background-color:#E0E0E0">|</span>    <span style="background-color:#E0E0E0">|</span> <span style="background-color:#E0E0E0">_( <a href="../../src/sem_phase/idl-sem_phase-fix_pre.adb">fix_pre</a>  </span>
                                           <span style="background-color:#E0E0E0">|</span>    <span style="background-color:#E0E0E0">|</span> <span style="background-color:#E0E0E0">_[ <a href="../../src/sem_phase/idl-sem_phase-fix_with.adb">fix_with</a> </span>
                                           <span style="background-color:#E0E0E0">|</span>    <span style="background-color:#E0E0E0">|</span> <span style="background-color:#E0E0E0">_[ <a href="../../src/sem_phase/idl-sem_phase-gen_subs.adb">gen_subs</a> </span>
                                           <span style="background-color:#E0E0E0">|</span>    <span style="background-color:#E0E0E0">|</span> <span style="background-color:#E0E0E0">_[ <a href="../../src/sem_phase/idl-sem_phase-hom_unit.adb">hom_unit</a> </span>
                                           <span style="background-color:#E0E0E0">|</span>    <span style="background-color:#E0E0E0">|</span> <span style="background-color:#E0E0E0">_[ <a href="../../src/sem_phase/idl-sem_phase-instant.adb">instant</a>  </span>
                                           <span style="background-color:#E0E0E0">|</span>    <span style="background-color:#E0E0E0">|</span> <span style="background-color:#E0E0E0">_[ <a href="../../src/sem_phase/idl-sem_phase-make_nod.adb">make_nod</a> </span>
                                           <span style="background-color:#E0E0E0">|</span>    <span style="background-color:#E0E0E0">|</span> <span style="background-color:#E0E0E0">_[ <a href="../../src/sem_phase/idl-sem_phase-newsnam.adb">newsnam</a>  </span>
                                           <span style="background-color:#E0E0E0">|</span>    <span style="background-color:#E0E0E0">|</span> <span style="background-color:#E0E0E0">_[ <a href="../../src/sem_phase/idl-sem_phase-nod_walk.adb">nod_walk</a> </span>
                                           <span style="background-color:#E0E0E0">|</span>    <span style="background-color:#E0E0E0">|</span> <span style="background-color:#E0E0E0">_[ <a href="../../src/sem_phase/idl-sem_phase-pra_walk.adb">pra_walk</a> </span>
                                           <span style="background-color:#E0E0E0">|</span>    <span style="background-color:#E0E0E0">|</span> <span style="background-color:#E0E0E0">_[ <a href="../../src/sem_phase/idl-sem_phase-pre_fcns.adb">pre_fcns</a> </span>
                                           <span style="background-color:#E0E0E0">|</span>    <span style="background-color:#E0E0E0">|</span> <span style="background-color:#E0E0E0">_[ <a href="../../src/sem_phase/idl-sem_phase-red_subp.adb">red_subp</a> </span>
                                           <span style="background-color:#E0E0E0">|</span>    <span style="background-color:#E0E0E0">|</span> <span style="background-color:#E0E0E0">_[ <a href="../../src/sem_phase/idl-sem_phase-rep_clau.adb">rep_clau</a> </span>
                                           <span style="background-color:#E0E0E0">|</span>    <span style="background-color:#E0E0E0">|</span> <span style="background-color:#E0E0E0">_[ <a href="../../src/sem_phase/idl-sem_phase-req_util.adb">req_util</a> </span>
                                           <span style="background-color:#E0E0E0">|</span>    <span style="background-color:#E0E0E0">|</span> <span style="background-color:#E0E0E0">_[ <a href="../../src/sem_phase/idl-sem_phase-sem_glob.adb">sem_glob</a> </span>
                                           <span style="background-color:#E0E0E0">|</span>    <span style="background-color:#E0E0E0">|</span> <span style="background-color:#E0E0E0">_[ <a href="../../src/sem_phase/idl-sem_phase-set_util.adb">set_util</a> </span>
                                           <span style="background-color:#E0E0E0">|</span>    <span style="background-color:#E0E0E0">|</span> <span style="background-color:#E0E0E0">_[ <a href="../../src/sem_phase/idl-sem_phase-stm_walk.adb">stm_walk</a> </span>
                                           <span style="background-color:#E0E0E0">|</span>    <span style="background-color:#E0E0E0">|</span> <span style="background-color:#E0E0E0">_[ <a href="../../src/sem_phase/idl-sem_phase-uarith.adb">uarith</a>   </span>
                                           <span style="background-color:#E0E0E0">|</span>    <span style="background-color:#E0E0E0">|</span> <span style="background-color:#E0E0E0">_[ <a href="../../src/sem_phase/idl-sem_phase-univ_ops.adb">univ_ops</a> </span>
                                           <span style="background-color:#E0E0E0">|</span>    <span style="background-color:#E0E0E0">|</span> <span style="background-color:#E0E0E0">_[ <a href="../../src/sem_phase/idl-sem_phase-vis_util.adb">vis_util</a> </span>
                                           <span style="background-color:#E0E0E0">|</span> <span style="background-color:#E0E0E0">_( <a href="../../src/ada_comp/idl-err_phase.adb">err_phase</a>     </span>
                                           <span style="background-color:#E0E0E0">|</span> <span style="background-color:#E0E0E0">_( <a href="../../src/ada_comp/idl-write_lib.adb">write_lib</a>     </span>


</pre>

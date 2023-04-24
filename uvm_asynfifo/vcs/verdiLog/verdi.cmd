simSetSimulator "-vcssv" -exec "./simv" -args " " -uvmDebug on
debImport "-i" "-simflow" "-dbdir" "./simv.daidir"
srcHBSelect "tb.du" -win $_nTrace1
srcHBSelect "tb.du" -win $_nTrace1
srcHBSelect "tb.rd_if" -win $_nTrace1
srcHBSelect "tb.du" -win $_nTrace1
srcTBInvokeSim
srcHBSelect "tb.du" -win $_nTrace1
wvCreateWindow
srcHBAddObjectToWave -clipboard
wvDrop -win $_nWave3
srcTBRunSim
srcTBSimBreak
wvSetCursor -win $_nWave3 359549204.553818 -snap {("du" 7)}
wvZoomAll -win $_nWave3
wvZoom -win $_nWave3 0.000000 41091901.103956
wvZoom -win $_nWave3 75606.073788 4422955.316617
wvZoom -win $_nWave3 123598.889717 1127448.622881
verdiWindowResize -win $_Verdi_1 "0" "144" "889" "626"
wvZoomIn -win $_nWave3
wvZoomIn -win $_nWave3
wvZoomIn -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomIn -win $_nWave3
wvSetCursor -win $_nWave3 549696.755120 -snap {("du" 9)}
wvSetCursor -win $_nWave3 583323.938012 -snap {("du" 8)}
wvSetCursor -win $_nWave3 581941.998989 -snap {("du" 9)}
wvSelectSignal -win $_nWave3 {( "du" 3 )} 
wvSelectSignal -win $_nWave3 {( "du" 4 )} 
wvSetCursor -win $_nWave3 677295.791571 -snap {("du" 8)}
verdiDockWidgetSetCurTab -dock widgetDock_<Message>
verdiDockWidgetSetCurTab -dock windowDock_OneSearch
verdiDockWidgetSetCurTab -dock windowDock_InteractiveConsole_2
verdiDockWidgetSetCurTab -dock windowDock_nWave_3
wvSetCursor -win $_nWave3 210790.329531 -snap {("du" 4)}
wvZoomOut -win $_nWave3
wvSetCursor -win $_nWave3 543562.682353 -snap {("du" 9)}
wvZoomIn -win $_nWave3
wvSetCursor -win $_nWave3 583178.267677 -snap {("du" 6)}
wvSetCursor -win $_nWave3 618187.389592 -snap {("du" 6)}
wvSetCursor -win $_nWave3 661948.791984 -snap {("du" 6)}
wvSetCursor -win $_nWave3 576729.218904 -snap {("du" 9)}
wvSetCursor -win $_nWave3 620951.267637 -snap {("du" 6)}
wvSetCursor -win $_nWave3 661488.145643 -snap {("du" 6)}
wvSetCursor -win $_nWave3 699261.145604 -snap {("du" 8)}
wvSetCursor -win $_nWave3 619569.328614 -snap {("du" 6)}
debExit

#!/usr/bin/env python3
# -*- coding: utf-8 -*-

#
# SPDX-License-Identifier: GPL-3.0
#
# GNU Radio Python Flow Graph
# Title: Udp2Fosphor
# Author: Marsiau
# GNU Radio version: 3.10.6.0

from packaging.version import Version as StrictVersion
from PyQt5 import Qt
from gnuradio import qtgui
from PyQt5 import Qt
import sip
from gnuradio import fosphor
from gnuradio.fft import window
from PyQt5.QtCore import QObject, pyqtSlot
from gnuradio import blocks
from gnuradio import gr
from gnuradio.filter import firdes
import sys
import signal
from argparse import ArgumentParser
from gnuradio.eng_arg import eng_float, intx
from gnuradio import eng_notation
from gnuradio import network
from gnuradio.qtgui import Range, RangeWidget
from PyQt5 import QtCore
from xmlrpc.client import ServerProxy



class udp2fosphor(gr.top_block, Qt.QWidget):

    def __init__(self):
        gr.top_block.__init__(self, "Udp2Fosphor", catch_exceptions=True)
        Qt.QWidget.__init__(self)
        self.setWindowTitle("Udp2Fosphor")
        qtgui.util.check_set_qss()
        try:
            self.setWindowIcon(Qt.QIcon.fromTheme('gnuradio-grc'))
        except BaseException as exc:
            print(f"Qt GUI: Could not set Icon: {str(exc)}", file=sys.stderr)
        self.top_scroll_layout = Qt.QVBoxLayout()
        self.setLayout(self.top_scroll_layout)
        self.top_scroll = Qt.QScrollArea()
        self.top_scroll.setFrameStyle(Qt.QFrame.NoFrame)
        self.top_scroll_layout.addWidget(self.top_scroll)
        self.top_scroll.setWidgetResizable(True)
        self.top_widget = Qt.QWidget()
        self.top_scroll.setWidget(self.top_widget)
        self.top_layout = Qt.QVBoxLayout(self.top_widget)
        self.top_grid_layout = Qt.QGridLayout()
        self.top_layout.addLayout(self.top_grid_layout)

        self.settings = Qt.QSettings("GNU Radio", "udp2fosphor")

        try:
            if StrictVersion(Qt.qVersion()) < StrictVersion("5.0.0"):
                self.restoreGeometry(self.settings.value("geometry").toByteArray())
            else:
                self.restoreGeometry(self.settings.value("geometry"))
        except BaseException as exc:
            print(f"Qt GUI: Could not restore geometry: {str(exc)}", file=sys.stderr)

        ##################################################
        # Variables
        ##################################################
        self.center_F = center_F = 800.0
        self.samp_rate = samp_rate = 2457.6e6
        self.packet_size = packet_size = 8192//2
        self.ip_address = ip_address = "Insert your own IP"
        self.center_f = center_f = center_F*1e6

        ##################################################
        # Blocks
        ##################################################

        self.qtgui_tab = Qt.QTabWidget()
        self.qtgui_tab_widget_0 = Qt.QWidget()
        self.qtgui_tab_layout_0 = Qt.QBoxLayout(Qt.QBoxLayout.TopToBottom, self.qtgui_tab_widget_0)
        self.qtgui_tab_grid_layout_0 = Qt.QGridLayout()
        self.qtgui_tab_layout_0.addLayout(self.qtgui_tab_grid_layout_0)
        self.qtgui_tab.addTab(self.qtgui_tab_widget_0, 'gr-fosphor')
        self.qtgui_tab_widget_1 = Qt.QWidget()
        self.qtgui_tab_layout_1 = Qt.QBoxLayout(Qt.QBoxLayout.TopToBottom, self.qtgui_tab_widget_1)
        self.qtgui_tab_grid_layout_1 = Qt.QGridLayout()
        self.qtgui_tab_layout_1.addLayout(self.qtgui_tab_grid_layout_1)
        self.qtgui_tab.addTab(self.qtgui_tab_widget_1, 'waterfall')
        self.top_layout.addWidget(self.qtgui_tab)
        # Create the options list
        self._samp_rate_options = [2457600000.0, 1228800000.0, 614400000.0, 307200000.0]
        # Create the labels list
        self._samp_rate_labels = ['d = 2, fs = 2457.6e6', 'd = 4, fs =  1228.8e6', 'd = 8, fs = 614.4e6', 'd = 16, fs = 307.2e6']
        # Create the combo box
        self._samp_rate_tool_bar = Qt.QToolBar(self)
        self._samp_rate_tool_bar.addWidget(Qt.QLabel("Sample rate" + ": "))
        self._samp_rate_combo_box = Qt.QComboBox()
        self._samp_rate_tool_bar.addWidget(self._samp_rate_combo_box)
        for _label in self._samp_rate_labels: self._samp_rate_combo_box.addItem(_label)
        self._samp_rate_callback = lambda i: Qt.QMetaObject.invokeMethod(self._samp_rate_combo_box, "setCurrentIndex", Qt.Q_ARG("int", self._samp_rate_options.index(i)))
        self._samp_rate_callback(self.samp_rate)
        self._samp_rate_combo_box.currentIndexChanged.connect(
            lambda i: self.set_samp_rate(self._samp_rate_options[i]))
        # Create the radio buttons
        self.qtgui_tab_grid_layout_0.addWidget(self._samp_rate_tool_bar, 0, 1, 1, 1)
        for r in range(0, 1):
            self.qtgui_tab_grid_layout_0.setRowStretch(r, 1)
        for c in range(1, 2):
            self.qtgui_tab_grid_layout_0.setColumnStretch(c, 1)
        self.xmlrpc_client_0_0 = ServerProxy('http://'+ip_address+':8080')
        self.xmlrpc_client_0 = ServerProxy('http://'+ip_address+':8080')
        self.qtgui_waterfall_sink_x_0 = qtgui.waterfall_sink_c(
            4096, #size
            window.WIN_HAMMING, #wintype
            center_f, #fc
            samp_rate, #bw
            "", #name
            1, #number of inputs
            None # parent
        )
        self.qtgui_waterfall_sink_x_0.set_update_time(0.10)
        self.qtgui_waterfall_sink_x_0.enable_grid(False)
        self.qtgui_waterfall_sink_x_0.enable_axis_labels(True)



        labels = ['', '', '', '', '',
                  '', '', '', '', '']
        colors = [0, 0, 0, 0, 0,
                  0, 0, 0, 0, 0]
        alphas = [1.0, 1.0, 1.0, 1.0, 1.0,
                  1.0, 1.0, 1.0, 1.0, 1.0]

        for i in range(1):
            if len(labels[i]) == 0:
                self.qtgui_waterfall_sink_x_0.set_line_label(i, "Data {0}".format(i))
            else:
                self.qtgui_waterfall_sink_x_0.set_line_label(i, labels[i])
            self.qtgui_waterfall_sink_x_0.set_color_map(i, colors[i])
            self.qtgui_waterfall_sink_x_0.set_line_alpha(i, alphas[i])

        self.qtgui_waterfall_sink_x_0.set_intensity_range(-140, 10)

        self._qtgui_waterfall_sink_x_0_win = sip.wrapinstance(self.qtgui_waterfall_sink_x_0.qwidget(), Qt.QWidget)

        self.qtgui_tab_layout_1.addWidget(self._qtgui_waterfall_sink_x_0_win)
        self.qtgui_graphicitem_0 = self._qtgui_graphicitem_0_win = qtgui.GrGraphicItem('../assets/rfsoc-pynq.png',True,True,1,1)
        self._qtgui_graphicitem_0_win = self._qtgui_graphicitem_0_win
        self.qtgui_tab_grid_layout_0.addWidget(self._qtgui_graphicitem_0_win, 0, 0, 1, 1)
        for r in range(0, 1):
            self.qtgui_tab_grid_layout_0.setRowStretch(r, 1)
        for c in range(0, 1):
            self.qtgui_tab_grid_layout_0.setColumnStretch(c, 1)
        self.network_udp_source_0 = network.udp_source(gr.sizeof_short, 1, 60133, 0, packet_size, True, False, False)
        self.fosphor_qt_sink_c_0 = fosphor.qt_sink_c()
        self.fosphor_qt_sink_c_0.set_fft_window(window.WIN_HAMMING)
        self.fosphor_qt_sink_c_0.set_frequency_range(center_f, samp_rate)
        self._fosphor_qt_sink_c_0_win = sip.wrapinstance(self.fosphor_qt_sink_c_0.qwidget(), Qt.QWidget)
        self.qtgui_tab_grid_layout_0.addWidget(self._fosphor_qt_sink_c_0_win, 1, 0, 1, 4)
        for r in range(1, 2):
            self.qtgui_tab_grid_layout_0.setRowStretch(r, 1)
        for c in range(0, 4):
            self.qtgui_tab_grid_layout_0.setColumnStretch(c, 1)
        self._center_F_range = Range(-4195.2*1e6/2, 4195.2*1e6/2, 0.001, 800.0, 200)
        self._center_F_win = RangeWidget(self._center_F_range, self.set_center_F, "Center frequency (MHz):", "counter", float, QtCore.Qt.Horizontal)
        self.qtgui_tab_grid_layout_0.addWidget(self._center_F_win, 0, 2, 1, 1)
        for r in range(0, 1):
            self.qtgui_tab_grid_layout_0.setRowStretch(r, 1)
        for c in range(2, 3):
            self.qtgui_tab_grid_layout_0.setColumnStretch(c, 1)
        self.blocks_probe_rate_0 = blocks.probe_rate(gr.sizeof_gr_complex*1, 1000.0, 0.15)
        self.blocks_message_debug_1 = blocks.message_debug(True)
        self.blocks_message_debug_0 = blocks.message_debug(True)
        self.blocks_interleaved_short_to_complex_0 = blocks.interleaved_short_to_complex(False, False,32767)


        ##################################################
        # Connections
        ##################################################
        self.msg_connect((self.blocks_probe_rate_0, 'rate'), (self.blocks_message_debug_1, 'print'))
        self.msg_connect((self.fosphor_qt_sink_c_0, 'freq'), (self.blocks_message_debug_0, 'print'))
        self.connect((self.blocks_interleaved_short_to_complex_0, 0), (self.blocks_probe_rate_0, 0))
        self.connect((self.blocks_interleaved_short_to_complex_0, 0), (self.fosphor_qt_sink_c_0, 0))
        self.connect((self.blocks_interleaved_short_to_complex_0, 0), (self.qtgui_waterfall_sink_x_0, 0))
        self.connect((self.network_udp_source_0, 0), (self.blocks_interleaved_short_to_complex_0, 0))


    def closeEvent(self, event):
        self.settings = Qt.QSettings("GNU Radio", "udp2fosphor")
        self.settings.setValue("geometry", self.saveGeometry())
        self.stop()
        self.wait()

        event.accept()

    def get_center_F(self):
        return self.center_F

    def set_center_F(self, center_F):
        self.center_F = center_F
        self.set_center_f(self.center_F*1e6)
        self.xmlrpc_client_0_0.set_fc(self.center_F)

    def get_samp_rate(self):
        return self.samp_rate

    def set_samp_rate(self, samp_rate):
        self.samp_rate = samp_rate
        self._samp_rate_callback(self.samp_rate)
        self.fosphor_qt_sink_c_0.set_frequency_range(self.center_f, self.samp_rate)
        self.qtgui_waterfall_sink_x_0.set_frequency_range(self.center_f, self.samp_rate)
        self.xmlrpc_client_0.set_decimation(self.samp_rate)

    def get_packet_size(self):
        return self.packet_size

    def set_packet_size(self, packet_size):
        self.packet_size = packet_size

    def get_ip_address(self):
        return self.ip_address

    def set_ip_address(self, ip_address):
        self.ip_address = ip_address

    def get_center_f(self):
        return self.center_f

    def set_center_f(self, center_f):
        self.center_f = center_f
        self.fosphor_qt_sink_c_0.set_frequency_range(self.center_f, self.samp_rate)
        self.qtgui_waterfall_sink_x_0.set_frequency_range(self.center_f, self.samp_rate)




def main(top_block_cls=udp2fosphor, options=None):

    if StrictVersion("4.5.0") <= StrictVersion(Qt.qVersion()) < StrictVersion("5.0.0"):
        style = gr.prefs().get_string('qtgui', 'style', 'raster')
        Qt.QApplication.setGraphicsSystem(style)
    qapp = Qt.QApplication(sys.argv)

    tb = top_block_cls()

    tb.start()

    tb.show()

    def sig_handler(sig=None, frame=None):
        tb.stop()
        tb.wait()

        Qt.QApplication.quit()

    signal.signal(signal.SIGINT, sig_handler)
    signal.signal(signal.SIGTERM, sig_handler)

    timer = Qt.QTimer()
    timer.start(500)
    timer.timeout.connect(lambda: None)

    qapp.exec_()

if __name__ == '__main__':
    main()

import argparse
import os
import sys

from PyQt5 import QtWidgets
from PyQt5.QtCore import pyqtSignal, Qt
from PyQt5.QtGui import QPainter, QColor
from PyQt5.QtWidgets import (QWidget, QVBoxLayout, QPushButton, QTableWidget, QLineEdit, QFrame,
                             QHBoxLayout, QColorDialog, QApplication, QLabel, QSizePolicy, QFileDialog)

# Constants
NUM_ROWS = 6
PIXELS_PER_CHAR = 10


class ColorReliefEditor(QWidget):
    """
    Editor for RGB colors used by gdaldem color-relief
    Each row has: altitude R G B
    Display all the colors and allow you to edit each color and altitude
    See:  https://gdal.org/programs/gdaldem.html
    """

    def __init__(self, filename):
        super().__init__()
        self.filename = filename

        try:
            self.data = self.read_rgb_values()
        except FileNotFoundError as e:
            print(str(e))
            sys.exit()

        self.init_ui()

    def init_ui(self):
        # Create ColorPaneWidget - panel to edit colors
        self.color_pane_widget = ColorPaneWidget(self.data)

        # Create SampleView widget - panel to display a sample of the colors
        self.sample_view = ViewSample(self.data)

        # Connect the update event of ColorPaneWidget to redraw ViewSample
        self.color_pane_widget.data_updated.connect(self.sample_view.redraw)

        # Create the main display  with sample view, and color pane
        main_pane = QHBoxLayout()
        main_pane.addWidget(self.sample_view)
        main_pane.addWidget(self.color_pane_widget)
        self.setLayout(main_pane)

    def read_rgb_values(self):
        """Read RGB values from the file and return as a list."""
        if not os.path.exists(self.filename):
            raise FileNotFoundError(f"File {os.path.abspath(self.filename)} not found.")

        with open(self.filename, 'r') as file:
            lines = file.readlines()

            data = []
            for line in lines:
                tokens = line.strip().split()
                if len(tokens) == 4:  # If the line has height, R, G, B
                    y, r, g, b = map(int, tokens)
                    a = None
                elif len(tokens) == 5:  # If the line has height, R, G, B, A
                    y, r, g, b, a = map(int, tokens)
                data.append([y, r, g, b, a])

            return data

    def save_rgb_values(self):
        """Save RGB(A) values to the file."""
        with open(self.filename, 'w') as file:
            for row in self.data:
                file.write(" ".join(map(str, [value for value in row if value is not None])) + '\n')


class ColorPaneWidget(QWidget):
    """
    Display a row for each altitude and color in the file and allow editing
    """
    data_updated = pyqtSignal()  # A signal that data has updated

    def __init__(self, shared_data):
        super().__init__()
        self.data = shared_data
        self.init_ui()
        self.set_data_changed(False)

    def init_ui(self):
        ROW_HEIGHT = 30
        label_width = 9 * PIXELS_PER_CHAR
        color_frame_width = ROW_HEIGHT * 4

        # Create color table with height on left and color boxes on right
        self.color_table = QTableWidget(len(self.data), 2, self)
        self.color_table.horizontalHeader().setSectionResizeMode(
            1, QtWidgets.QHeaderView.ResizeToContents
        )
        self.color_table.horizontalHeader().hide()
        self.color_table.verticalHeader().hide()
        self.color_table.setFixedHeight(ROW_HEIGHT * len(self.data))

        # Each row has height in left column and color box in right column
        for idx, (height, r, g, b, a) in enumerate(self.data):
            # Add cell for editable height
            height_edit = QLineEdit(str(height))
            height_edit.setFixedHeight(ROW_HEIGHT)
            height_edit.setFixedWidth(label_width)
            height_edit.setAlignment(Qt.AlignBottom)
            height_edit.textEdited.connect(self.on_height_edited)
            self.color_table.setCellWidget(idx, 0, height_edit)

            # Add cell with button for each color.  Click brings up ColorPicker
            color_button = QPushButton(self)
            color_button.setFlat(True)  # This will make the button look like a plain rectangle
            if a is not None:  # If alpha value is provided
                color_button.setStyleSheet(
                    "background-color: rgba({}, {}, {}, {}); border: none;".format(r, g, b, a)
                )
            else:
                color_button.setStyleSheet(
                    "background-color: rgb({}, {}, {}); border: none;".format(r, g, b)
                    )
            color_button.setFixedSize(color_frame_width, ROW_HEIGHT)
            color_button.clicked.connect(lambda _, idx=idx: self.open_color_picker(idx))
            self.color_table.setCellWidget(idx, 1, color_button)

            self.color_table.setRowHeight(idx, ROW_HEIGHT)

        # Create Instructions
        instructions_label = QLabel("Click on height or color above to edit", self)

        # Create Save button
        self.save_button = QPushButton("Save", self)
        self.save_button.clicked.connect(self.save_rgb_values)
        self.save_button.setSizePolicy(QSizePolicy.Fixed, QSizePolicy.Fixed)

        # Create the layout
        layout = QVBoxLayout()
        layout.addWidget(self.color_table, 0)
        layout.addWidget(instructions_label, 0)
        layout.addWidget(self.save_button, 0, Qt.AlignTop)
        layout.addStretch(1)  # Push all widgets to the top
        self.setLayout(layout)

    def on_height_edited(self):
        """Called when the height value is edited in the table."""
        sender = self.sender()
        if sender:
            idx = self.color_table.indexAt(sender.pos()).row()
            if 0 <= idx < len(self.data):
                try:
                    self.data[idx][0] = int(sender.text())
                except ValueError:
                    pass  # Handle invalid conversion to integer if needed
                self.set_data_changed(True)  # a change has been made

    def open_color_picker(self, idx):
        print("Open Color Picker")
        # Use the QTableWidget to retrieve the QPushButton for the color
        color_button = self.color_table.cellWidget(idx, 1)

        # Extract RGB(A) values from the data
        r, g, b, a = self.data[idx][1:5]

        if a is None:  # If no alpha value
            current_color = QColor(r, g, b)
        else:
            current_color = QColor(r, g, b, a)

        dialog = QColorDialog(current_color)
        dialog.setOption(QColorDialog.ShowAlphaChannel, True)

        if dialog.exec_():
            new_color = dialog.currentColor()
            if new_color.isValid():
                self.data[idx][1], self.data[idx][2], self.data[idx][
                    3] = new_color.red(), new_color.green(), new_color.blue()
                # Check if alpha was originally present and update it
                if a is not None:
                    self.data[idx][4] = new_color.alpha()

            # Set the style for normal, pressed, and released states of the button
            color_style = """
                QPushButton {background-color: %s; border: none;}
                QPushButton:pressed {background-color: %s; border: none;}
                QPushButton:released {background-color: %s; border: none;}
            """ % (new_color.name(), new_color.name(), new_color.name())

            color_button.setStyleSheet(color_style)
            self.set_data_changed(True)  # a change has been made

    #             color_box.setStyleSheet("background-color: {}".format(new_color.name()))

    def save_rgb_values(self):
        self.parent().save_rgb_values()
        self.set_data_changed(False)

    def set_data_changed(self, changed: bool):
        self.save_button.setEnabled(changed)
        if changed:
            self.data_updated.emit()


class ViewSample(QWidget):
    def __init__(self, shared_data):
        super().__init__()
        self.data = shared_data
        self.setMinimumSize(220, 500)

    def calculate_draw_params(self):
        draw_params = []  # List to store parameters for drawRect
        # Determine minimum negative value and offset all values to be positive
        min_y = min(self.data, key=lambda x: x[0])[0]
        self.offset = -min_y if min_y < 0 else 0
        # Offset the y-values to make all of them positive
        self.offset_data = [(y + self.offset, r, g, b, a) for y, r, g, b, a in self.data]

        # Find the maximum y-value and calculate scale
        max_y_value = float(max(self.offset_data, key=lambda x: x[0])[0])
        pad = max_y_value * 0.1  # Add  space for the top bar
        scale_factor: float = float(self.height()) / float(max_y_value + pad)
        previous_y = self.height()  # Start from top

        for data_row in sorted(self.offset_data, key=lambda x: x[0], reverse=True):
            y_value, r, g, b, a = data_row
            scaled_y = int(float(y_value) * scale_factor)
            bar_height: int = max(1, previous_y - scaled_y)
            target_y = self.height() - (scaled_y + bar_height)

            if a is None:  # If alpha value is not provided
                draw_params.append((0, target_y, self.width(), bar_height, QColor(r, g, b)))
            else:
                draw_params.append((0, target_y, self.width(), bar_height, QColor(r, g, b, a)))
            previous_y = scaled_y

        return draw_params

    def paintEvent(self, event):
        painter = QPainter(self)

        # 0 is top, 1200 is bottom. x,y is top left rect corner
        for x, y, w, h, color in self.calculate_draw_params():
            painter.setBrush(color)
            painter.setPen(color)
            painter.drawRect(x, y, w, h)

        painter.end()

    def redraw(self):
        """Method to trigger a redraw."""
        self.update()


HELP_MESSAGE = """
Editor for the color text file used by gdaldem color-relief. 
color_text_file contains lines of the format: elevation_value red green blue
First argument is base for color text file: base-color-relief.txt
Display the colors and allow you to edit colors and elevations. 
"""



def main():
    app = QApplication(sys.argv)

    file_dialog = QFileDialog()
    file_dialog.setNameFilter("Color Ramp Files (*color_ramp.txt);;All Files (*)")
    file_dialog.setWindowTitle("Select Color Ramp File")
    file_dialog.setFileMode(QFileDialog.ExistingFile)

    if file_dialog.exec_() == QFileDialog.Accepted:
        selected_file = file_dialog.selectedFiles()[0]
    else:
        sys.exit(0)

    window = ColorReliefEditor(selected_file)
    window.setWindowTitle("Color Relief Table Editor")
    window.show()
    sys.exit(app.exec_())


if __name__ == '__main__':
    main()

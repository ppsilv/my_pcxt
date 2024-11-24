;    This file is part of the BIOS of the Tralala 8088 Homebrew Computer.
;
;    The BIOS of the Tralala 8088 Homebrew Computer is free software: you
;    can redistribute it and/or modify it under the terms of the GNU General
;    Public License as published by the Free Software Foundation, either
;    version 3 of the License, or (at your option) any later version.
;
;    The BIOS of the Tralala 8088 Homebrew Computer is distributed in the hope
;    that it will be useful, but WITHOUT ANY WARRANTY; without even the implied
;    warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;    GNU General Public License for more details.
;
;    You should have received a copy of the GNU General Public License
;    along with the BIOS.  If not, see <http://www.gnu.org/licenses/>.


                            %define ICH_COMMAND_PING 0x00
                            %define ICH_COMMAND_SEND_FF_TO_CONSOLE 0x01
                            %define ICH_COMMAND_CLEAR_CONSOLE 0x02
                            %define ICH_COMMAND_GET_STATUS 0x03
                            %define ICH_COMMAND_SD_READ_SECTOR 0x04
                            %define ICH_COMMAND_SD_WRITE_SECTOR 0x05
                            %define ICH_COMMAND_SET_CURSOR_POSITION 0x07
                            %define ICH_COMMAND_SET_TEXT_ATTR 0x08
                            %define ICH_COMMAND_CONSOLE_ERASE_WHOLE_DISPLAY 0x09
                            %define ICH_COMMAND_CONSOLE_ERASE_RECT 0x0A
                            %define ICH_COMMAND_CONSOLE_SCROLL_UP 0x0B
                            %define ICH_COMMAND_CONSOLE_SCROLL_DOWN 0x0C

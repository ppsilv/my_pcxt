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


                            cpu 8086
                            bits 16

                            times 12287-($-$$) db 0
                            db 0

Gotero
======

Gotero helps understanding the interactions between your objects through
sequence diagrams. It can generate those from any code block, but the main idea
is to build those from your tests.

Usage
-----

~~~ruby
g = Gotero.new
g.trace do
  #do some interesting stuff
end

puts g.output
#=> t->your_object: method (arguments)
#=> your_object-->t:
~~~

The output aims to be compatible with [js-sequence-diagrams][1] so they can be
displayed nicely in the browser.

 [1]: https://bramp.github.io/js-sequence-diagrams/

Licence
-------

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU Affero General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.

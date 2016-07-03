
finito = require '../../'

# TODO: allow to attach data to a state? that way stepper config can be one place
# first defining all states, then all transitions
def = finito.define 'full-stepping motor'
  .state '0'
  .state '1'
  .state '2'
  .state '3'

  .transition().from('0').to('1')._when('go_clockwise')
  .transition().from('1').to('2')._when('go_clockwise')
  .transition().from('2').to('3')._when('go_clockwise')
  .transition().from('3').to('0')._when('go_clockwise')

  .transition().from('1').to('0')._when('go_counterclockwise')
  .transition().from('2').to('1')._when('go_counterclockwise')
  .transition().from('3').to('2')._when('go_counterclockwise')
  .transition().from('3').to('0')._when('go_counterclockwise')

  .initial '0'
  .done()

# adding transitions for states as-you-go
def = finito.define 'full-stepping motor'
  .state '0'
    .to('1')._when('go_clockwise')
    .to('3')._when('go_counterclockwise')
  .state '1'
    .to('2')._when('go_clockwise')
    .to('0')._when('go_counterclockwise')
  .state '2'
    .to('3')._when('go_clockwise')
    .to('1')._when('go_counterclockwise')
  .state '3'
    .to('0')._when('go_clockwise')
    .to('2')._when('go_counterclockwise')
  .initial '0'
  .done()


module.exports = def

datagen = require './mockdata'

griddata = datagen(1000)
gridheight = 400
require 'es5-shim' #needed for phantom js
window.riot = require 'riot'
require '../lib/grid.js'
require './testtag.tag'
simulant = require 'simulant'

spyclick = null
spyclick2 = null
spyChange = null
test = {}
rows = null


describe 'grid',->

  beforeEach ->
    startTime = new Date().getTime()
    @domnode = document.createElement('div')
    @domnode.appendChild(document.createElement('testtag'))
    @node = document.body.appendChild(@domnode)
    spyclick = sinon.spy()
    spyclick2 = sinon.spy()
    spyChange = sinon.spy()
    @tag = riot.mount('testtag',{griddata:griddata,gridheight:gridheight,testclick:spyclick,testclick2:spyclick2,testchange:spyChange})[0]
    riot.update()
    rows = document.querySelectorAll('.gridrow')
    
  afterEach ->
    @tag.unmount()
    @domnode = ''

  it "should add grid to the document",->
    expect(document.querySelectorAll('testtag').length).to.equal(1)
    expect(document.querySelectorAll('grid').length).to.equal(1)

  it "should load data into the grid",->
    expect(document.querySelectorAll('.gridrow').length).to.be.gt(1)
    expect(@node.textContent).to.contain(griddata[0].first_name)
    expect(@node.innerHTML).to.contain(griddata[0].surname)

  it "should render only enough rows needed",->
    expect(document.querySelectorAll('.gridrow').length).to.be.lt((gridheight/30)+20)
    expect(document.querySelectorAll('.gridrow').length).to.be.gt(gridheight/30)

  it "should render only enough rows after scrolling",->
    document.querySelector('.gridbody').scrollTop = 1000
    expect(document.querySelectorAll('.gridrow').length).to.be.lt((gridheight/30)+20)
    expect(document.querySelectorAll('.gridrow').length).to.be.gt(gridheight/30)
   
  it "should render only enough rows after scrolling (again)",->
    document.querySelector('.gridbody').scrollTop = 4389
    expect(document.querySelectorAll('.gridrow').length).to.be.lt((gridheight/30)+20)
    expect(document.querySelectorAll('.gridrow').length).to.be.gt(gridheight/30)
 
  it "should change class to active when row is clicked",->
    expect(@domnode.querySelectorAll('.active').length).to.equal(0)
    simulant.fire(document.querySelector('.gridrow'),'click')
    expect(@domnode.querySelectorAll('.active').length).to.equal(1)

  it "should call onclick on row when row is clicked",->
    simulant.fire(document.querySelector('.gridrow'),'click')
    expect(spyclick.calledOnce).to.be.true
    expect(spyclick.args[0][0]).to.eql(griddata[0])

  it "should call ondblclick callback when row is double clicked",->
    simulant.fire(document.querySelectorAll('.gridrow')[2],'dblclick')
    expect(spyclick2.calledOnce).to.be.true
    expect(spyclick2.args[0][0]).to.eql(griddata[2])

  it "should select next item when down key is pressed",->
    simulant.fire(rows[0],'click')
    document.querySelector('grid').focus()
    expect(@domnode.querySelector('.active')).to.equal(rows[0])
    simulant.fire(document,'keydown',{keyCode:40})
    expect(@domnode.querySelector('.active')).to.equal(rows[1])

  it "should select next item when down key is pressed",->
    simulant.fire(rows[0],'click')
    document.querySelector('grid').focus()
    expect(@domnode.querySelector('.active')).to.equal(rows[0])
    simulant.fire(document,'keydown',{keyCode:40})
    expect(@domnode.querySelector('.active')).to.equal(rows[1])

  it "should select previous item when up key is pressed",->
    simulant.fire(rows[3],'click')
    document.querySelector('grid').focus()
    expect(@domnode.querySelector('.active')).to.equal(rows[3])
    simulant.fire(document,'keydown',{keyCode:38})
    expect(@domnode.querySelector('.active')).to.equal(rows[2])
    simulant.fire(document,'keydown',{keyCode:38})
    expect(@domnode.querySelector('.active')).to.equal(rows[1])
    simulant.fire(document,'keydown',{keyCode:38})
    expect(@domnode.querySelector('.active')).to.equal(rows[0])

  it "should not change on keypress if not focused",->
    simulant.fire(rows[2],'click')
    expect(@domnode.querySelector('.active')).to.equal(rows[2])
    simulant.fire(document,'keydown',{keyCode:38})
    expect(@domnode.querySelector('.active')).to.equal(rows[2])

  it "should fire onchange on keypress",->
    simulant.fire(rows[3],'click')
    document.querySelector('grid').focus()
    expect(@domnode.querySelector('.active')).to.equal(rows[3])
    simulant.fire(document,'keydown',{keyCode:38})
    expect(spyChange.calledTwice).to.be.true

  it "should select multiple and all in between with shift click",->
    simulant.fire(rows[3],'click')
    simulant.fire(rows[5],'click',{shiftKey:true})
    expect(spyChange.calledTwice).to.be.true
    expect(@domnode.querySelector('.active')).to.equal(rows[3])
    expect(spyChange.args[1][0].length).to.equal(3)

  it "should add one at a time if meta-clicked",->
    simulant.fire(rows[3],'click')
    simulant.fire(rows[5],'click',{metaKey:true})
    expect(@domnode.querySelectorAll('.active').length).to.equal(2)
    expect(spyChange.args[1][0]).to.eql([griddata[3],griddata[5]])

  it "should deselect row if meta-clicked",->
    simulant.fire(rows[20],'click')
    expect(@domnode.querySelectorAll('.active').length).to.equal(1)
    simulant.fire(rows[20],'click',{metaKey:true})
    expect(@domnode.querySelectorAll('.active').length).to.equal(0)
 
  it "should select multiple with shift+arrow keys",->
    simulant.fire(rows[3],'click')
    document.querySelector('grid').focus()
    expect(@domnode.querySelectorAll('.active').length).to.equal(1)
    simulant.fire(document,'keydown',{keyCode:38,shiftKey:true})
    expect(@domnode.querySelectorAll('.active').length).to.equal(2)

describe 'grid without data',->

  beforeEach ->
    startTime = new Date().getTime()
    @domnode = document.createElement('div')
    @domnode.appendChild(document.createElement('testtag2'))
    @node = document.body.appendChild(@domnode)
    spyclick = sinon.spy()
    spyclick2 = sinon.spy()
    
  afterEach ->
    @tag.unmount()
    @domnode = ''

  it "should add grid without data",->
    @tag = riot.mount('testtag2',{gridheight:gridheight,testclick:spyclick,testclick2:spyclick2})[0]
    riot.update()
    expect(document.querySelectorAll('testtag2').length).to.equal(1)
    expect(document.querySelectorAll('grid').length).to.equal(1)
    expect(document.querySelectorAll('.gridrow').length).to.equal(0)

  it "should not hightlight without a callback function",->
    @tag = riot.mount('testtag2',{griddata:griddata,gridheight:gridheight,testclick2:spyclick2})[0]
    riot.update()   
    expect(@domnode.querySelectorAll('.active').length).to.equal(0)
    simulant.fire(document.querySelector('.gridrow'),'click')
    expect(@domnode.querySelectorAll('.active').length).to.equal(0)

  it "should not hightlight on double click without a callback function",->
    @tag = riot.mount('testtag2',{griddata:griddata,gridheight:gridheight,testclick2:spyclick2})[0]
    riot.update()   
    expect(@domnode.querySelectorAll('.active').length).to.equal(0)
    simulant.fire(document.querySelector('.gridrow'),'dblclick')
    expect(@domnode.querySelectorAll('.active').length).to.equal(0)

  it "should set active rows if passed in",->
    @tag = riot.mount('testtag2',{griddata:griddata,gridheight:gridheight,activerow:[griddata[1]]})[0]
    riot.update()   
    expect(@domnode.querySelectorAll('.active').length).to.equal(1)

  it "should set multiple active rows if passed in",->
    @tag = riot.mount('testtag2',{griddata:griddata,gridheight:gridheight,activerow:[griddata[1],griddata[3],griddata[5]]})[0]
    riot.update()   
    expect(@domnode.querySelectorAll('.active').length).to.equal(3)

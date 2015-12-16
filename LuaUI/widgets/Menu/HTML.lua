-- TODO: combine 'html > table > chili' into 'html > chili'
--        flex html library to create chili objects instead of creating a table
-- TODO: enable 'head' where scripts, css, and psuedonyms* can be defined and handled seperately from the html layout
--        *a psuedonym will be any tag that is tied to a usable chili class other than
--         it can be treated like a 'themed' class, or could be used for convenience

local Document = Control:New{
  x=0,y=0,right=0,bottom=0,
  name = 'HTML',
  psuedo = {
    label = 'Label',
    p = 'TextBox',
    textbox = 'TextBox',
    Textbox = 'TextBox',
    panel = 'Panel',
    div = 'Panel',
  }
}

function Document:BuildChili(tag, obj)
    local Class = Chili[self.psuedo[tag] or tag]
    if not Class then
      Spring.Echo('[ERROR] HTML Parser - No Chili Class or psuedonym matched the tag ' .. tag)
      Spring.Echo('        - Creating Chili.Control with html attributes')
      return Control:New(obj)
    end
    return Class:New(obj)
end

function Document:GetChili(root, parent)
  -- if root._tag:lowercase() == 'script' then
  --
  -- end

  for k, v in pairs(root) do
    if self:type(k,v) == 'content' and parent.text then
      parent:SetText(v)
    elseif self:type(k,v) == 'content' and parent.caption then
      parent:SetCaption(v)
    elseif self:type(k,v) == 'element' then
      local control = self:BuildChili(v._tag, v._attr)
      parent:AddChild(control)
      self:GetChili(v, control)
    end
  end
end

function Document:type(k, v)
  return k ~= '_tag' and k ~= '_attr' and type(v) == 'table' and 'element' or
         k ~= '_tag' and k ~= '_attr' and type(v) == 'string' and 'content'
end

Document:GetChili(VFS.Include("libs/html/html.lua")(VFS.LoadFile('libs/html/Test.html')), Document)

return Document

require "/scripts/vec2.lua"
require "/scripts/poly.lua"
require "/scripts/util.lua"

function init()
    pane_config = config.getParameter("humanoid_config")
    stance_maker_option = root.assetJson("/d8spmcce/scripts/interface/stance_maker/stance_maker_config.json")
    self.currentOption = "meleeWeapon.lua"
    self.twohanded = false
    if self.weapon_x == nil then
        self.weapon_x = 0
    end
    if self.weapon_y == nil then
        self.weapon_y = 0
    end
    if self.image_x == nil then
        self.image_x = 0
    end
    if self.image_y == nil then
        self.image_y = 0
    end
    if widget.getText("tab_default.weapon_path") == "" then
        self.weapon_path = "/assetmissing.png"
    else
        self.weapon_path = widget.getText("tab_default.weapon_path")
    end

    if widget.getText("tab_hitbox.slash_path") == "" then
        self.slash_path = "/assetmissing.png"
    else
        self.slash_path = widget.getText("tab_hitbox.slash_path")
    end

    if self.hitbox_offset == nil then
        self.hitbox_offset = {0, 0}
    end

    if self.hitbox == nil then
        self.hitbox = {}
    end
    
    if self.window == nil then
        self.window = "stance"
    end

    if self.dummy_offset == nil then
        self.dummy_offset = {0,0}
    end

    self.weapon_angle_value_test = 0

    self.dummy_position = pane_config["dummy_position"]
    self.dummy_f_arm_position = {self.dummy_position[1] - pane_config["backArmOffset"][1], self.dummy_position[2] - pane_config["backArmOffset"][2]}
    self.dummy_b_arm_position = {self.dummy_f_arm_position[1] + pane_config["backArmOffset"][1], self.dummy_f_arm_position[2] + pane_config["backArmOffset"][2]}
    self.weapon_init_position = {(self.dummy_f_arm_position[1] + pane_config["frontHandPosition"][1]) + 0.8, self.dummy_f_arm_position[2] + pane_config["frontHandPosition"][2]}
    self.mannequin_head_path = "/items/armors/biome/icecaves/icearmor/head.png:normal"
    self.mannequin_body_path = "/items/armors/biome/icecaves/icearmor/chestm.png:chest.1"
    self.mannequin_pants_path = "/items/armors/biome/icecaves/icearmor/pants.png:idle.1"
    self.mannequin_frontarm_path = "/items/armors/biome/icecaves/icearmor/fsleeve.png:%s"
    self.mannequin_backarm_path = "/items/armors/biome/icecaves/icearmor/bsleeve.png:%s"
    self.rotation_point_image = "/d8spmcce/texture/interface/stance_maker/rotation_point.png"

    if not self.frontarm_frame ~= nil then
        self.frontarm_frame = "rotation"
    end

    if not self.backarm_frame ~= nil then
        self.backarm_frame = "rotation"
    end 

    self.farm_full = string.format(self.mannequin_frontarm_path, self.frontarm_frame)
    self.barm_full = string.format(self.mannequin_backarm_path, self.backarm_frame)
    local color = {255, 255, 255, 255}
    
    self.canvas = widget.bindCanvas("Dummy")

    self.hitboxDefaultAngle = stance_maker_option[self.currentOption]["hitboxDefaultAngle"]
    if self.hitboxDefaultAngle == "math.pi/2" then
        self.hitboxDefaultAngle = math.pi/2
    end
    sb.logInfo("hitboxDefaultAngle = %s", self.hitboxDefaultAngle)
    hitbox_init()
end

function render_canvas()
    local hitbox = copy(self.hitbox)
    self.canvas:clear()
    local arm_base_rotation = -((math.pi/180) * 90)
    self.weapon_angle_value_test = self.weapon_angle_value_test + (math.pi/180)
    self.farm_full = string.format(self.mannequin_frontarm_path, self.frontarm_frame)
    self.barm_full = string.format(self.mannequin_backarm_path, self.backarm_frame)
    if tonumber(widget.getText("dummy_offset_value_1")) ~= nil then
        self.dummy_offset[1] = tonumber(widget.getText("dummy_offset_value_1")) * 8
    else
        self.dummy_offset[1] = 0
    end

    if tonumber(widget.getText("dummy_offset_value_2")) ~= nil then
        self.dummy_offset[2] = tonumber(widget.getText("dummy_offset_value_2")) * 8
    else
        self.dummy_offset[2] = 0
    end

    if self.twohanded == false then
        self.canvas:drawImageDrawable(string.format(self.mannequin_backarm_path, "idle.1"),    {self.b_arm_position[1] + self.dummy_offset[1], self.b_arm_position[2] + self.dummy_offset[2]},  1, color, 0)
    else
        self.canvas:drawImageDrawable(self.barm_full,    {self.b_arm_position[1] + self.dummy_offset[1], self.b_arm_position[2] + self.dummy_offset[2]},  1, color, self.f_arm_angle)
    end

    self.canvas:drawImageDrawable(self.mannequin_pants_path, {self.dummy_position[1] + self.dummy_offset[1], self.dummy_position[2] + self.dummy_offset[2]},  1, color)
    self.canvas:drawImageDrawable(self.slash_path, {(self.new_slash_position[1] + self.dummy_offset[1]), (self.new_slash_position[2] + self.dummy_offset[2])},  1, color, self.weapon_angle_value + (math.pi/2))
    self.canvas:drawImageDrawable(self.mannequin_head_path, {self.dummy_position[1] + self.dummy_offset[1], self.dummy_position[2] + self.dummy_offset[2]},  1, color)
    self.canvas:drawImageDrawable(self.mannequin_body_path, {self.dummy_position[1] + self.dummy_offset[1], self.dummy_position[2] + self.dummy_offset[2]},  1, color)
    self.canvas:drawImageDrawable(self.weapon_path, {self.new_weapon_position[1] + self.dummy_offset[1], self.new_weapon_position[2] + self.dummy_offset[2]},  1, color, self.weapon_angle_value)
    self.canvas:drawImageDrawable(self.farm_full,   {self.f_arm_position[1] + self.dummy_offset[1], self.f_arm_position[2] + self.dummy_offset[2]},  1, color, self.f_arm_angle)
    self.canvas:drawImageDrawable(self.rotation_point_image, {self.weapon_position[1] + self.dummy_offset[1], self.weapon_position[2] + self.dummy_offset[2]}, 1, color)
    hitbox = poly.scale(hitbox, 8)
    hitbox = poly.rotate(hitbox, self.weapon_angle_value)
    hitbox = poly.rotate(hitbox, (math.pi/2))
    hitbox = poly.translate(hitbox, {(self.new_slash_position[1] + self.dummy_offset[1]), (self.new_slash_position[2] + self.dummy_offset[2])})
    self.canvas:drawPoly(hitbox, {255, 255, 0, 255}, 1)
end

function update()
    weapon_position()
    render_canvas()
end

function hitbox_init()
    hb_clear()
end

function hitbox_populate_list()
    local list = "tab_hitbox.hitbox_list.list"
    widget.clearListItems(list)
    for index, value in pairs(self.hitbox) do
        local id = widget.addListItem(list)
        local slot = string.format("%s.%s", list, id)

        widget.setText(string.format("%s.itemName", slot), string.format("^yellow;%s", sb.printJson(value)))

        widget.setData(slot,
            {
                index = index,
                hitbox = value
            }
        )

        if index == self.current_HB_Index then
            widget.setListSelected("tab_hitbox.hitbox_list.list", id)
        end
    end
end

function hitbox_select()
    local select = widget.getListSelected("tab_hitbox.hitbox_list.list")

    if select then
        self.HB_data = (widget.getData(string.format("tab_hitbox.hitbox_list.list.%s", select)))
        self.current_HB_Index = self.HB_data.index
        self.current_HB_Value = self.HB_data.hitbox
        self.current_HB_Select = select
        widget.setText("tab_hitbox.hitbox_value_1", self.current_HB_Value[1])
        widget.setText("tab_hitbox.hitbox_value_2", self.current_HB_Value[2])
    end
end

function hitbox_button()
    if self.window ~= "hitbox" then
        self.window = "hitbox"
        widget.setVisible("tab_default", false)
        widget.setVisible("tab_hitbox", true)
    else
        self.window = "stance"
        widget.setVisible("tab_default", true)
        widget.setVisible("tab_hitbox", false)
    end
end

function hb_add()
    local added_index = nil

    for a, _ in pairs(self.hitbox) do
        added_index = a + 1
    end

    if added_index == nil then
        added_index = 1
    end

    table.insert(self.hitbox, added_index, {0,0})
    hitbox_populate_list()
end

function hb_save()
        self.current_HB_Value[1] = tonumber(widget.getText("tab_hitbox.hitbox_value_1"))
        self.current_HB_Value[2] = tonumber(widget.getText("tab_hitbox.hitbox_value_2"))

    if self.current_HB_Value[1] ~= nil and self.current_HB_Value[2] ~= nil and self.current_HB_Index ~= nil then
        table.remove(self.hitbox, self.current_HB_Index)
        table.insert(self.hitbox, self.current_HB_Index, {self.current_HB_Value[1], self.current_HB_Value[2]})
        hitbox_populate_list()
    end
end

function hb_remove()
    if self.current_HB_Index ~= nil then
        table.remove(self.hitbox, self.current_HB_Index)
        self.current_HB_Select = nil
        self.current_HB_Index = nil
        hitbox_populate_list()
    end
end

function hb_clear()    
    self.hitbox = {}
    self.current_HB_Select = nil
    self.current_HB_Value = {0, 0}
    self.current_HB_Index = nil
    hitbox_populate_list()
end

function confirm_box()
    if widget.hasFocus("tab_default.weapon_path") then
        if widget.getText("tab_default.weapon_path") ~= "" then
            self.weapon_path = widget.getText("tab_default.weapon_path")
        else
            self.weapon_path = "/assetmissing.png"
        end
    end

    if widget.hasFocus("tab_hitbox.slash_path") then
        if widget.getText("tab_hitbox.slash_path") ~= "" then
            self.slash_path = widget.getText("tab_hitbox.slash_path")
        else
            self.slash_path = "/assetmissing.png"
        end
    end

    if widget.hasFocus("tab_default.image_position_value_y") then
        if widget.getText("tab_default.image_position_value_y") ~= "" then
            self.frontarm_frame = widget.getText("tab_default.image_position_value_y")
        else
            self.frontarm_frame = "rotation"
        end
    end

    if widget.hasFocus("tab_default.image_position_value_x") then
        if widget.getText("tab_default.image_position_value_x") ~= "" then
            self.backarm_frame = widget.getText("tab_default.image_position_value_x")
        else
            self.backarm_frame = "rotation"
        end
    end

    widget.blur("tab_default.f_arm_angle_value")
    widget.blur("tab_default.weapon_angle_value")
    widget.blur("tab_default.weapon_position_value_x")
    widget.blur("tab_default.weapon_position_value_y")
    widget.blur("tab_hitbox.hitbox_position_value_x")
    widget.blur("tab_hitbox.hitbox_position_value_y")
    widget.blur("tab_default.image_position_value_x")
    widget.blur("tab_default.image_position_value_y")
    widget.blur("tab_default.weapon_path")
    widget.blur("tab_hitbox.slash_path")
    widget.blur("tab_hitbox.hitbox_value_1")
    widget.blur("tab_hitbox.hitbox_value_2")
    widget.blur("dummy_offset_value_1")
    widget.blur("dummy_offset_value_2")
end

function print()
	local stance = {
        frontArmFrame = self.frontarm_frame,
        backArmFrame = self.backarm_frame,
		armRotation = self.armRotation,
		weaponRotation = self.weaponRotation,
		weaponRotationCenter = {0,0},
		weaponOffset = {self.weapon_x_angle, self.weapon_y_angle},
		armAngularVelocity = 0,
        weaponAngularVelocity = 0,
        twoHanded = self.twohanded,
		burstParticleEmitters = {
			"<particle>"
		},
		animationStates = {
		  "<state>\" = \"<default>"
		},
		playSounds = {
			"<sound>"
		},
        allowRotate = false,
        allowFlip = true
	}
    local animationCustom = {
        damageArea = self.hitbox,
        offset = {self.hitbox_offset[2], -self.hitbox_offset[1]},
        image = self.slash_path
	}
	sb.logInfo("[Stance Maker Json Dump]\n<stanceName> :\n%s", sb.printJson(stance, 1))
    sb.logInfo("[Stance Maker Json Dump]\n<animationCustom> :\n%s", sb.printJson(animationCustom, 1))
end

function twohanded()
    if self.twohanded ~= true then
        self.twohanded = true
        widget.setText("tab_default.twohanded_button", "True")
    else
        self.twohanded = false
        widget.setText("tab_default.twohanded_button", "False")
    end
end

function weapon_position()
    
    if widget.getText("tab_default.f_arm_angle_value") ~= "" and widget.getText("tab_default.f_arm_angle_value") ~= "-" then
        self.f_arm_angle = (math.pi/180) * tonumber(widget.getText("tab_default.f_arm_angle_value"))
        self.f_arm_angle_value = (math.pi/180) * tonumber(widget.getText("tab_default.f_arm_angle_value"))
        self.armRotation = tonumber(widget.getText("tab_default.f_arm_angle_value"))
    else
        self.f_arm_angle = 0
        self.f_arm_angle_value = 0
        self.armRotation = 0
    end
    
    if tonumber(widget.getText("tab_default.weapon_angle_value")) ~= nil and tonumber(widget.getText("tab_default.weapon_angle_value")) ~= "-" then
        self.weapon_angle_value = ((math.pi/180) * tonumber(widget.getText("tab_default.weapon_angle_value"))) + self.f_arm_angle_value
        self.weaponRotation = tonumber(widget.getText("tab_default.weapon_angle_value"))
    else
        self.weapon_angle_value = self.f_arm_angle_value
        self.weaponRotation = 0
    end

    if tonumber(widget.getText("tab_default.weapon_position_value_x")) ~= nil then
        self.weapon_x = tonumber(widget.getText("tab_default.weapon_position_value_x")) * 8
		self.weapon_x_angle = tonumber(widget.getText("tab_default.weapon_position_value_x"))
    else
        self.weapon_x = 0
		self.weapon_x_angle = 0
    end

    if tonumber(widget.getText("tab_default.weapon_position_value_y")) ~= nil then
        self.weapon_y = tonumber(widget.getText("tab_default.weapon_position_value_y")) * 8
		self.weapon_y_angle = tonumber(widget.getText("tab_default.weapon_position_value_y"))
    else
        self.weapon_y = 0
		self.weapon_y_angle = 0
    end

    if tonumber(widget.getText("tab_hitbox.hitbox_position_value_x")) ~= nil then
        self.hitbox_offset[1] = -tonumber(widget.getText("tab_hitbox.hitbox_position_value_x"))
    else
        self.hitbox_offset[1] = 0
    end

    if tonumber(widget.getText("tab_hitbox.hitbox_position_value_y")) ~= nil then
        self.hitbox_offset[2] = tonumber(widget.getText("tab_hitbox.hitbox_position_value_y"))
    else
        self.hitbox_offset[2] = 0
    end

    if self.f_arm_angle == nil then
        self.f_arm_angle = 0
    end

    local a = {self.dummy_f_arm_position[1], self.dummy_f_arm_position[2]-1}
    local b = {self.dummy_f_arm_position[1]+3, self.dummy_f_arm_position[2]}
    local r = self.f_arm_angle

    self.f_arm_position = {
        (math.cos(r) * (b[1]-a[1]) - math.sin(r) * (b[2]-a[2]) + a[1]),
        (math.sin(r) * (b[1]-a[1]) + math.cos(r) * (b[2]-a[2]) + a[2])
    }
    local a = {self.dummy_f_arm_position[1], self.dummy_f_arm_position[2]}
    local b = {self.dummy_f_arm_position[1]+2, self.dummy_f_arm_position[2]}
    local r = self.f_arm_angle

    self.b_arm_position = {
        (math.cos(r) * (b[1]-a[1]) - math.sin(r) * (b[2]-a[2]) + a[1]),
        (math.sin(r) * (b[1]-a[1]) + math.cos(r) * (b[2]-a[2]) + a[2])
    }

    local a = self.dummy_f_arm_position
    local b = {self.weapon_init_position[1], self.weapon_init_position[2]}
    local r = self.f_arm_angle_value

    self.weapon_position = {
        (math.cos(r) * (b[1]-a[1]) - math.sin(r) * (b[2]-a[2]) + a[1]),
        (math.sin(r) * (b[1]-a[1]) + math.cos(r) * (b[2]-a[2]) + a[2])
    }

    local a = {self.weapon_position[1], self.weapon_position[2]}
    local b = {self.weapon_position[1] + (self.weapon_x + self.image_x), self.weapon_position[2] + ((self.weapon_y + self.image_y))}
    local r = self.weapon_angle_value
    
    self.weapon_position_rotation = {
        (math.cos(r) * (b[1]-a[1]) - math.sin(r) * (b[2]-a[2]) + a[1]),
        (math.sin(r) * (b[1]-a[1]) + math.cos(r) * (b[2]-a[2]) + a[2])
    }

    self.new_weapon_position = self.weapon_position_rotation
    
    local a = {self.weapon_position[1], self.weapon_position[2]}
    local b = {self.weapon_position[1] + (((self.weapon_x + self.image_x + (self.hitbox_offset[1] * 8)))), self.weapon_position[2] + (((self.weapon_y + self.image_y + (self.hitbox_offset[2] * 8))))}
    
    self.slash_position_rotation = {
        (math.cos(r) * (b[1]-a[1]) - math.sin(r) * (b[2]-a[2]) + a[1]),
        (math.sin(r) * (b[1]-a[1]) + math.cos(r) * (b[2]-a[2]) + a[2])
    }

    self.new_slash_position = self.slash_position_rotation
end

function clear_weapon()
    widget.setText("tab_default.weapon_path", "")
    self.weapon_path = "/assetmissing.png"
end

function clear_slash()
    widget.setText("tab_hitbox.slash_path", "")
    self.slash_path = "/assetmissing.png"
end

function uninit()

end
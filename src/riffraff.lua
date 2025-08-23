RIFFRAFF_POPUP_SECONDS = 5
RIFFRAFF_CONTESTED_POPUP_SECONDS = 2

function create_riffraff_queue()
    G.riffraff_area = CardArea(
        0, 0,
        0.95 * G.CARD_W,
        0.95 * G.CARD_H,
        {card_limit = 1, type = 'title', highlight_limit = 0, collection = true})

    G.RIFFRAFF_QUEUE = G.RIFFRAFF_QUEUE or {
    queue = {},
    active = false,
    add_card = function(self, card)
        if G.E_MANAGER.queues['riffraff'] and #G.E_MANAGER.queues['riffraff'] > 0 then
            for j = 1, #G.E_MANAGER.queues['riffraff'] do
                G.E_MANAGER.queues['riffraff'][j].delay = RIFFRAFF_CONTESTED_POPUP_SECONDS * G.SETTINGS.GAMESPEED
            end
        end
        table.insert(self.queue, card)
        self:process_queue()
    end,
    process_queue = function(self)
        if self.active or #self.queue == 0 then return end
        local card = table.remove(self.queue, 1)
        if not card or not card.config or not card.config.center then
            return
        end

        local center = card.config.center
        self.active = true
        local card_copy = Card(G.riffraff_area.T.x, G.riffraff_area.T.y,
                               G.CARD_W, G.CARD_H, G.P_CARDS.empty, center)
        card_copy.config.riffraff_display = true

        if center.config then
            center.config.riffraff_display = true
        end
        G.riffraff_area:emplace(card_copy)
        card_copy:hover()
        if center.config then
            center.config.riffraff_display = nil
        end

        local delay = RIFFRAFF_POPUP_SECONDS * G.SETTINGS.GAMESPEED
        if #self.queue > 0 then
            delay = RIFFRAFF_CONTESTED_POPUP_SECONDS * G.SETTINGS.GAMESPEED
        end

        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = delay,
            blocking = false,
            blockable = false,
            func = (function()
                clear_riffraff_queue(true)
                G.RIFFRAFF_QUEUE.active = false
                G.RIFFRAFF_QUEUE:process_queue()
                return true
            end)
        }), 'riffraff')
    end
    }
    G.RIFFRAFF_QUEUE.active = false
end

function clear_riffraff_queue(visible)
    if G.riffraff_area and G.riffraff_area.cards and #G.riffraff_area.cards > 0 then
        for j = #G.riffraff_area.cards, 1, -1 do
            local card = G.riffraff_area.cards[j]
            G.riffraff_area:remove_card(card)
            if visible then
                Node.stop_hover(card)
                card:start_dissolve({G.C.GOLD}, nil, 1)
            else
                card:remove()
            end
            card = nil
        end
    end
end
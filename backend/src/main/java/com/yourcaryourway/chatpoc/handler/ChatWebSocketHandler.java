package com.yourcaryourway.chatpoc.handler;

import java.net.URI;
import java.time.Instant;
import java.util.Map;
import java.util.Set;
import java.util.concurrent.ConcurrentHashMap;

import org.springframework.stereotype.Component;
import org.springframework.web.socket.CloseStatus;
import org.springframework.web.socket.TextMessage;
import org.springframework.web.socket.WebSocketSession;
import org.springframework.web.socket.handler.TextWebSocketHandler;
import org.springframework.web.util.UriComponentsBuilder;

import tools.jackson.databind.ObjectMapper;
import com.yourcaryourway.chatpoc.model.ChatMessage;
import com.yourcaryourway.chatpoc.validation.ChatMessageValidator;

@Component
public class ChatWebSocketHandler extends TextWebSocketHandler {

    private final Map<String, Set<WebSocketSession>> conversations =
            new ConcurrentHashMap<>();

    private final ObjectMapper objectMapper;

    private final ChatMessageValidator messageValidator;

    public ChatWebSocketHandler(
        ObjectMapper objectMapper,
        ChatMessageValidator messageValidator) {

        this.objectMapper = objectMapper;
        this.messageValidator = messageValidator;
    }

    @Override
    public void afterConnectionEstablished(WebSocketSession session) {
        String conversationId = getConversationId(session);

        conversations
                .computeIfAbsent(
                        conversationId,
                        key -> ConcurrentHashMap.newKeySet())
                .add(session);
    }

    @Override
    protected void handleTextMessage(
            WebSocketSession session,
            TextMessage message) throws Exception {

        String conversationId = getConversationId(session);

        ChatMessage chatMessage =
                objectMapper.readValue(
                        message.getPayload(),
                        ChatMessage.class);

        if (!messageValidator.isValid(chatMessage)) {
            return;
        }

        chatMessage.setConversationId(conversationId);
        chatMessage.setTimestamp(Instant.now());

        String payload =
                objectMapper.writeValueAsString(chatMessage);

        Set<WebSocketSession> sessions =
                conversations.get(conversationId);

        if (sessions == null) {
            return;
        }

        for (WebSocketSession connectedSession : sessions) {
            if (connectedSession.isOpen()) {
                connectedSession.sendMessage(
                        new TextMessage(payload));
            }
        }
    }

    @Override
    public void afterConnectionClosed(
            WebSocketSession session,
            CloseStatus status) {

        String conversationId = getConversationId(session);

        Set<WebSocketSession> sessions =
                conversations.get(conversationId);

        if (sessions == null) {
            return;
        }

        sessions.remove(session);

        if (sessions.isEmpty()) {
            conversations.remove(conversationId);
        }
    }

    private String getConversationId(WebSocketSession session) {
        URI uri = session.getUri();

        if (uri == null) {
            return "default";
        }

        String conversationId = UriComponentsBuilder
                .fromUri(uri)
                .build()
                .getQueryParams()
                .getFirst("conversationId");

        if (conversationId == null || conversationId.isBlank()) {
            return "default";
        }

        return conversationId;
    }
}
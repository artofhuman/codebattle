defmodule Codebattle.Chat.Server do
  def start_link(id) do
    GenServer.start_link(__MODULE__, [], name: chat_key(id))
  end

  def join_chat(id, user) do
    GenServer.call(chat_key(id), {:join, user})
  end

  def leave_chat(id, user) do
    GenServer.call(chat_key(id), {:leave, user})
  end

  def get_users(id) do
    GenServer.call(chat_key(id), :get_users)
  end

  def add_msg(id, user, msg) do
    GenServer.cast(chat_key(id), {:add_msg, user, msg})
  end

  def get_msgs(id) do
    GenServer.call(chat_key(id), :get_msgs)
  end

  defp chat_key(id) do
    {:via, :gproc, {:n, :l, {:chat, to_charlist(id)}}}
  end

  def init(_) do
    {:ok, %{users: [], messages: []}}
  end

  def handle_call({:join, user}, _from, state) do
    %{users: users} = state

    new_users =
      case Enum.member?(users, user) do
        false -> [user | users]
        _ -> users
      end

    {:reply, {:ok, new_users}, %{state | users: new_users}}
  end

  def handle_call({:leave, user}, _from, state) do
    %{users: users} = state
    new_users = Enum.filter(users, fn u -> u != user end)
    {:reply, {:ok, new_users}, %{state | users: new_users}}
  end

  def handle_call(:get_users, _from, state) do
    %{users: users} = state
    {:reply, users, state}
  end

  def handle_call(:get_msgs, _from, state) do
    %{messages: messages} = state
    {:reply, messages, state}
  end

  def handle_cast({:add_msg, user, msg}, state) do
    %{messages: messages} = state
    new_msgs = [%{user: user, message: msg} | messages]
    {:noreply, %{state | messages: new_msgs}}
  end
end

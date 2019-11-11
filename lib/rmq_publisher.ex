defmodule ElixirPopularity.RMQPublisher do
  @behaviour GenRMQ.Publisher

  @rmq_uri "amqp://rabbitmq:rabbitmq@localhost:5672"
  @hn_exchange "hn_analytics"
  @hn_item_ids_queue "item_ids"
  @hn_bulk_item_data_queue "bulk_item_data"
  @publish_options [persistent: false]

  def init do
    create_rmq_resources()

    [
      uri: @rmq_uri,
      exchange: @hn_exchange
    ]
  end

  def start_link do
    GenRMQ.Publisher.start_link(__MODULE__, name: __MODULE__)
  end

  def hn_id_queue_size do
    GenRMQ.Publisher.message_count(__MODULE__, @hn_item_ids_queue)
  end

  def publish_hn_id(hn_id) do
    GenRMQ.Publisher.publish(__MODULE__, hn_id, @hn_item_ids_queue, @publish_options)
  end

  def publish_hn_items(items) do
    GenRMQ.Publisher.publish(__MODULE__, items, @hn_bulk_item_data_queue, @publish_options)
  end

  def item_id_queue_name, do: @hn_item_ids_queue

  def bulk_item_data_queue_name, do: @hn_bulk_item_data_queue

  defp create_rmq_resources do
    # Setup RabbitMQ connection
    {:ok, connection} = AMQP.Connection.open(@rmq_uri)
    {:ok, channel} = AMQP.Channel.open(connection)

    # Create exchange
    AMQP.Exchange.declare(channel, @hn_exchange, :topic, durable: true)

    # Create queues
    AMQP.Queue.declare(channel, @hn_item_ids_queue, durable: true)
    AMQP.Queue.declare(channel, @hn_bulk_item_data_queue, durable: true)

    # Bind queues to exchange
    AMQP.Queue.bind(channel, @hn_item_ids_queue, @hn_exchange, routing_key: @hn_item_ids_queue)
    AMQP.Queue.bind(channel, @hn_bulk_item_data_queue, @hn_exchange, routing_key: @hn_bulk_item_data_queue)

    # Close the channel as it is no longer needed
    # GenRMQ will manage its own channel
    AMQP.Channel.close(channel)
  end
end

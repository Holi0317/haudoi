export interface InsertFormProps {
  /**
   * Query string for the route/page, with leading `?`
   *
   * For restoring query after edit.
   */
  qs: string;
}

export function InsertForm(props: InsertFormProps) {
  const { qs } = props;

  return (
    <form method="post" action="/basic/insert">
      <label>
        <input type="url" name="url" />
        <input type="hidden" name="qs" value={qs} />
      </label>

      <input type="submit" value="Add link" />
    </form>
  );
}
